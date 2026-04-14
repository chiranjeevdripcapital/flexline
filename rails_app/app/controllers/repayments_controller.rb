# frozen_string_literal: true

class RepaymentsController < ApplicationController
  def index
    @installments =
      Installment
        .joins(:draw)
        .where(draws: { organization_id: current_organization.id })
        .includes(:draw)
        .due_first
  end
end
