# frozen_string_literal: true

class RepaymentsController < ApplicationController
  def index
    @payment_date_groups = PaymentDateGroup.for_organization(current_organization)
  end
end
