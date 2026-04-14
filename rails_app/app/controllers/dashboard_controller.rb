# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @draws = [
      { id: "FL-24001", amount: "$25,000", term: "6 mo", status: "Funded", updated: "Apr 2, 2026" },
      { id: "FL-24002", amount: "$12,500", term: "3 mo", status: "Processing", updated: "Apr 10, 2026" },
    ]
  end
end
