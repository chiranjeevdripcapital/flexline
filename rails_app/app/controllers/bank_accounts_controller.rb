# frozen_string_literal: true

class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: %i[
    show
    plaid_complete
    plaid_link_token
    plaid_exchange
    micro_confirm
    restart_verification
    use_micro_deposits_instead
  ]

  def index
    @accounts = current_organization.bank_accounts.order(primary_for_disbursement: :desc, created_at: :desc)
  end

  def new
    @bank_account = current_organization.bank_accounts.new(
      account_type: "checking",
      verification_method: "plaid",
      primary_for_disbursement: default_primary_flag?
    )
  end

  def create
    @bank_account = current_organization.bank_accounts.new(create_bank_account_params)

    unless @bank_account.save(context: :details)
      render :new, status: :unprocessable_entity
      return
    end

    if @bank_account.plaid?
      @bank_account.update!(verification_status: "awaiting_plaid")
      redirect_to bank_account_path(@bank_account), notice: "Account saved. Complete instant verification with Plaid, or switch to micro-deposits."
    else
      @bank_account.initiate_micro_deposits!
      redirect_to bank_account_path(@bank_account), notice: "Two small deposits are on the way. They typically arrive in 1–2 business days."
    end
  rescue StandardError => e
    Rails.logger.error("[bank_accounts#create] #{e.class}: #{e.message}")
    @bank_account.errors.add(:base, "Something went wrong starting verification. Please try again or contact support.")
    render :new, status: :unprocessable_entity
  end

  def plaid_link_token
    unless @bank_account.verification_status == "awaiting_plaid"
      render json: { error: "invalid_state" }, status: :unprocessable_entity
      return
    end

    token = Flexline::PlaidGateway.create_link_token(bank_account: @bank_account)
    render json: { link_token: token }
  rescue Flexline::PlaidGateway::ConfigurationError
    render json: { error: "plaid_not_configured" }, status: :service_unavailable
  rescue Plaid::ApiError => e
    Rails.logger.error("[bank_accounts#plaid_link_token] #{e.class}: #{e.message}")
    render json: { error: "plaid_error", message: e.message }, status: :bad_gateway
  end

  def plaid_exchange
    unless @bank_account.verification_status == "awaiting_plaid"
      render json: { error: "invalid_state" }, status: :unprocessable_entity
      return
    end

    Flexline::PlaidGateway.exchange_and_finalize_bank_account!(
      bank_account: @bank_account,
      public_token: params.require(:public_token),
      plaid_account_id: params.require(:plaid_account_id)
    )
    FlexlineMailer.bank_account_verified(@bank_account).deliver_later
    render json: { ok: true, redirect_path: bank_account_path(@bank_account) }
  rescue Flexline::PlaidGateway::ConfigurationError
    render json: { error: "plaid_not_configured" }, status: :service_unavailable
  rescue Plaid::ApiError => e
    Rails.logger.error("[bank_accounts#plaid_exchange] #{e.class}: #{e.message}")
    render json: { error: "plaid_error", message: e.message }, status: :bad_gateway
  rescue ActionController::ParameterMissing => e
    render json: { error: "missing_parameter", message: e.message }, status: :unprocessable_entity
  end

  def plaid_complete
    unless @bank_account.verification_status == "awaiting_plaid"
      redirect_to bank_account_path(@bank_account), alert: "This account is not waiting on Plaid."
      return
    end

    unless plaid_simulation_allowed?
      redirect_to bank_account_path(@bank_account),
                  alert: "Plaid Link is not enabled in this environment. Use micro-deposit verification instead."
      return
    end

    item_id = params[:item_id].presence || "plaid_demo_item"
    account_id = params[:account_id].presence || "plaid_demo_account"
    @bank_account.complete_plaid_verification!(item_id: item_id, account_id: account_id)
    FlexlineMailer.bank_account_verified(@bank_account).deliver_later
    redirect_to bank_account_path(@bank_account), notice: "Bank account verified. You can use it for draw disbursements."
  rescue StandardError => e
    Rails.logger.error("[bank_accounts#plaid_complete] #{e.class}: #{e.message}")
    redirect_to bank_account_path(@bank_account), alert: "Could not complete Plaid verification. Try again or use micro-deposits."
  end

  def micro_confirm
    unless @bank_account.micro_deposit_confirmable?
      redirect_to bank_account_path(@bank_account), alert: "Micro-deposit confirmation is not available for this account right now."
      return
    end

    a = dollars_to_cents(params[:amount_a].to_s)
    b = dollars_to_cents(params[:amount_b].to_s)

    if a <= 0 || b <= 0 || a > 99 || b > 99
      redirect_to bank_account_path(@bank_account), alert: "Enter each micro-deposit as cents between $0.01 and $0.99 (e.g. 0.32 for thirty-two cents)."
      return
    end

    if @bank_account.confirm_micro_deposit_amounts!(amount_a_cents: a, amount_b_cents: b)
      FlexlineMailer.bank_account_verified(@bank_account).deliver_later
      redirect_to bank_account_path(@bank_account), notice: "Bank account verified. You can use it for draw disbursements."
    else
      msg =
        if @bank_account.verification_status == "failed"
          @bank_account.failure_reason.presence || "Verification failed."
        else
          "Those amounts do not match our records. Check your bank feed and try again."
        end
      redirect_to bank_account_path(@bank_account), alert: msg
    end
  end

  def use_micro_deposits_instead
    unless @bank_account.verification_status == "awaiting_plaid"
      redirect_to bank_account_path(@bank_account), alert: "Micro-deposit fallback is only available during Plaid verification."
      return
    end

    @bank_account.switch_from_plaid_to_micro!
    redirect_to bank_account_path(@bank_account), notice: "Switched to micro-deposits. Two small deposits are on the way."
  rescue StandardError => e
    Rails.logger.error("[bank_accounts#use_micro_deposits_instead] #{e.class}: #{e.message}")
    redirect_to bank_account_path(@bank_account), alert: "Could not switch to micro-deposits. Try again or contact support."
  end

  def restart_verification
    unless @bank_account.restartable?
      redirect_to bank_account_path(@bank_account), alert: "Verified accounts cannot be restarted here. Add a different account if details changed."
      return
    end

    if @bank_account.draws.exists?
      @bank_account.restart_verification!
      redirect_to bank_account_path(@bank_account),
                  notice: "Verification progress was reset. This account already has draw history, so it was kept on file."
    else
      @bank_account.destroy!
      redirect_to new_bank_account_path, notice: "Bank account removed from the portal. Add it again when you are ready."
    end
  end

  private

  def set_bank_account
    @bank_account = current_organization.bank_accounts.find(params[:id])
  end

  def default_primary_flag?
    !current_organization.bank_accounts.verified.exists?
  end

  def create_bank_account_params
    params.require(:bank_account).permit(
      :display_name,
      :legal_name_on_account,
      :account_type,
      :routing_number,
      :account_number,
      :verification_method,
      :primary_for_disbursement
    )
  end

  # Plaid "complete without Link" is for local development only — not shown in customer-facing UAT/production.
  def plaid_simulation_allowed?
    Rails.env.development?
  end

  def dollars_to_cents(raw)
    s = raw.to_s.strip.delete(",")
    return 0 if s.blank?

    ((BigDecimal(s) * 100).round).to_i
  rescue ArgumentError
    0
  end
end
