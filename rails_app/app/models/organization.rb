# frozen_string_literal: true

class Organization < ApplicationRecord
  PORTAL_STATUSES = %w[active suspended].freeze

  has_many :users, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :draws, dependent: :destroy

  validates :name, presence: true
  validates :credit_limit_cents, numericality: { greater_than: 0 }
  validates :available_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :portal_status, inclusion: { in: PORTAL_STATUSES }
  validates :importer_external_id, uniqueness: { allow_blank: true }

  validate :available_within_limit

  def portal_active?
    portal_status == "active"
  end

  # Principal on funded draws that is not yet marked paid (scheduled instalments).
  # No funded draws or no schedule yet → 0.
  def outstanding_principal_cents
    Installment
      .joins(:draw)
      .where(draws: { organization_id: id, status: "funded" })
      .where(installments: { status: "scheduled" })
      .sum(:principal_cents)
  end

  # Borrower-facing headroom: facility limit minus unpaid principal on funded draws.
  def available_for_draws_cents
    [ credit_limit_cents.to_i - outstanding_principal_cents.to_i, 0 ].max
  end

  def public_draw_code(draw)
    return "DRAFT" unless draw.id

    format("FL-%05d", draw.id)
  end

  private

  def available_within_limit
    return if available_cents.blank? || credit_limit_cents.blank?

    errors.add(:available_cents, "cannot exceed credit limit") if available_cents > credit_limit_cents
  end
end
