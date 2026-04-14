# frozen_string_literal: true

class Organization < ApplicationRecord
  PORTAL_STATUSES = %w[active suspended].freeze

  has_many :users, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :draws, dependent: :destroy
  has_many :admin_events, dependent: :nullify
  has_many :bank_removal_requests, dependent: :destroy

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

  def verified_bank_accounts
    bank_accounts.where(verification_status: "verified")
  end

  def multiple_verified_bank_accounts?
    verified_bank_accounts.count >= 2
  end

  def pending_bank_removal_request_for?(account)
    bank_removal_requests.pending_review.exists?(bank_account_id: account.id)
  end

  def ensure_primary_verified_bank_account!
    return if bank_accounts.verified.exists?(primary_for_disbursement: true)

    next_primary = bank_accounts.verified.order(:created_at).first
    next_primary&.update!(primary_for_disbursement: true)
  end

  private

  def available_within_limit
    return if available_cents.blank? || credit_limit_cents.blank?

    errors.add(:available_cents, "cannot exceed credit limit") if available_cents > credit_limit_cents
  end
end
