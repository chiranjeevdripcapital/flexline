# frozen_string_literal: true

class DrawRequestsController < ApplicationController
  def new
    @draw = current_organization.draws.new(term_months: 6)
    @verified_accounts = current_organization.bank_accounts.verified.order(:display_name)
    @amount_dollars_raw = "25000"
  end

  def create
    @verified_accounts = current_organization.bank_accounts.verified.order(:display_name)
    @amount_dollars_raw = params.dig(:draw, :amount_dollars).to_s

    @draw = current_organization.draws.new(draw_attributes)

    unless @draw.save
      render :new, status: :unprocessable_entity
      return
    end

    unless @draw.submit_and_fund!
      messages = @draw.errors.full_messages
      messages << "Unable to fund draw." if messages.empty?
      @draw.destroy
      @draw = current_organization.draws.new(draw_attributes)
      messages.each { |m| @draw.errors.add(:base, m) }
      render :new, status: :unprocessable_entity
      return
    end

    redirect_to draw_request_path(@draw), notice: "Draw funded (demo schedule created)."
  end

  def show
    @draw = current_organization.draws.find(params[:id])
  end

  private

  def draw_attributes
    permitted = params.require(:draw).permit(:amount_dollars, :term_months, :bank_account_id)
    {
      bank_account_id: permitted[:bank_account_id],
      term_months: permitted[:term_months].to_i,
      amount_cents: dollars_to_cents(permitted[:amount_dollars].to_s),
    }
  end

  def dollars_to_cents(raw)
    s = raw.to_s.strip.delete(",")
    return 0 if s.blank?

    ((BigDecimal(s) * 100).round).to_i
  rescue ArgumentError
    0
  end
end
