# frozen_string_literal: true

class BankRemovalRequestsController < ApplicationController
  before_action :set_bank_account, only: %i[new create]
  before_action :ensure_removal_eligible!, only: %i[new create]

  def index
    @requests = current_organization.bank_removal_requests.recent_first.includes(:bank_account)
  end

  def new
    @removal_request = BankRemovalRequest.new(organization: current_organization, bank_account: @bank_account)
  end

  def create
    @removal_request = current_organization.bank_removal_requests.build(removal_params.merge(bank_account: @bank_account))
    if @removal_request.save
      AdminEvent.record!(
        action: "bank_removal_requested",
        actor_identifier: "portal:#{current_user.email}",
        organization: current_organization,
        bank_account: @bank_account,
        metadata: {
          "bank_removal_request_id" => @removal_request.id,
          "preview" => @removal_request.borrower_reason.truncate(200)
        }
      )
      redirect_to bank_accounts_path,
        notice: "Removal request submitted. Operations will review it; this account stays active until approved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_bank_account
    @bank_account = current_organization.bank_accounts.find(params[:bank_account_id])
  end

  def ensure_removal_eligible!
    unless @bank_account.verified?
      redirect_to bank_account_path(@bank_account), alert: "Only verified accounts can go through this removal flow."
      return
    end
    unless current_organization.multiple_verified_bank_accounts?
      redirect_to bank_account_path(@bank_account),
        alert: "You must keep at least one verified bank account. Add and verify another account before requesting removal."
      return
    end
    return unless current_organization.pending_bank_removal_request_for?(@bank_account)

    redirect_to bank_account_path(@bank_account), alert: "A removal request for this account is already awaiting review."
  end

  def removal_params
    params.require(:bank_removal_request).permit(:borrower_reason)
  end
end
