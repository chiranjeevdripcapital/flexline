# frozen_string_literal: true

module Admin
  class DrawsController < Admin::ApplicationController
    def index
      @draws = Draw.includes(:organization, :bank_account).recent_first.limit(100)
    end

    def show
      @draw = Draw.includes(:organization, :bank_account, :installments).find(params[:id])
    end

    def approve
      @draw = Draw.find(params[:id])
      if @draw.approve_and_fund!
        FlexlineMailer.draw_funded(@draw).deliver_later
        redirect_to admin_draw_path(@draw), notice: "Draw funded and instalments created."
      else
        redirect_to admin_draw_path(@draw), alert: @draw.errors.full_messages.presence || "Could not fund draw."
      end
    end

    def decline
      @draw = Draw.find(params[:id])
      reason = params[:decline_reason].to_s.strip.presence
      if @draw.decline!(reason: reason)
        FlexlineMailer.draw_declined(@draw).deliver_later
        redirect_to admin_draw_path(@draw), notice: "Draw marked declined."
      else
        redirect_to admin_draw_path(@draw), alert: @draw.errors.full_messages.presence || "Could not decline draw."
      end
    end
  end
end
