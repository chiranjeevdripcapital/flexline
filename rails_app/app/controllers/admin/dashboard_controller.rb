# frozen_string_literal: true

module Admin
  class DashboardController < Admin::ApplicationController
    def index
      @draw_counts = Draw.group(:status).count
      @bank_counts = BankAccount.group(:verification_status).count
      @pending_bank_removals = BankRemovalRequest.pending_review.count
    end
  end
end
