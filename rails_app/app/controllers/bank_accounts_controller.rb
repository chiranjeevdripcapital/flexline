# frozen_string_literal: true

class BankAccountsController < ApplicationController
  def index
    @accounts = [
      { label: "Operating · JPM · ···4421", status: "Verified" },
      { label: "Payroll · BoA · ···8890", status: "Pending" },
    ]
  end

  def new; end

  def create
    redirect_to bank_accounts_path, notice: "Bank account flow not implemented yet."
  end
end
