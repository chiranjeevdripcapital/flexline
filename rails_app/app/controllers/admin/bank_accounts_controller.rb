# frozen_string_literal: true

module Admin
  class BankAccountsController < Admin::ApplicationController
    PER_PAGE = 40

    def index
      scope = BankAccount.includes(:organization).order(created_at: :desc)
      st = params[:verification_status].to_s.strip
      if st.present? && BankAccount::VERIFICATION_STATUSES.include?(st)
        scope = scope.where(verification_status: st)
      end
      vm = params[:verification_method].to_s.strip
      if vm.present? && BankAccount::VERIFICATION_METHODS.include?(vm)
        scope = scope.where(verification_method: vm)
      end
      if params[:org_q].to_s.strip.present?
        term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:org_q].strip.downcase)}%"
        scope = scope.joins(:organization).where("LOWER(organizations.name) LIKE ?", term)
      end
      @page = [ params[:page].to_i, 1 ].max
      @total_count = scope.count
      @bank_accounts = scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    end
  end
end
