# frozen_string_literal: true

# Groups per-draw installments that share the same calendar due date so the portal can
# show one ACH debit total per payment date (facility consolidates to one pull per month).
class PaymentDateGroup
  attr_reader :due_on, :installments

  def initialize(due_on, installments)
    @due_on = due_on
    @installments = installments.sort_by { |i| [ i.draw_id, i.sequence ] }
  end

  def self.for_organization(organization)
    rows =
      Installment
        .joins(:draw)
        .where(draws: { organization_id: organization.id, status: "funded" })
        .includes(:draw)
        .order(:due_on, :sequence)
        .to_a

    rows
      .group_by(&:due_on)
      .map { |date, list| new(date, list) }
      .sort_by(&:due_on)
  end

  def ach_debit_cents
    installments.sum(&:amount_cents)
  end

  def principal_cents
    installments.sum(&:principal_cents)
  end

  def interest_cents
    installments.sum(&:interest_cents)
  end

  # Single status for the consolidated row: paid only if every underlying line is paid.
  def status
    installments.all? { |i| i.status == "paid" } ? "paid" : "scheduled"
  end
end
