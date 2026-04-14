# frozen_string_literal: true

module Admin
  class DashboardController < Admin::ApplicationController
    def index
      @draw_counts = Draw.group(:status).count
      @bank_counts = BankAccount.group(:verification_status).count
    end
  end
end
