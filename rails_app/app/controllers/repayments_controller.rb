# frozen_string_literal: true

class RepaymentsController < ApplicationController
  def index
    @rows = [
      { due: "May 15, 2026", amount: "$4,420.12", principal: "$3,980.00", interest: "$440.12", status: "Scheduled" },
      { due: "Jun 15, 2026", amount: "$4,420.12", principal: "$4,010.00", interest: "$410.12", status: "Scheduled" },
      { due: "Apr 15, 2026", amount: "$4,200.00", principal: "$3,900.00", interest: "$300.00", status: "Paid" },
    ]
  end
end
