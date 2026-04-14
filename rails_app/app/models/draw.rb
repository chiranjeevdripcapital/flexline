# frozen_string_literal: true

class Draw < ApplicationRecord
  belongs_to :organization
  belongs_to :bank_account

  has_many :installments, dependent: :destroy

  STATUSES = %w[processing funded declined].freeze
  TERMS = [ 3, 6 ].freeze

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :term_months, inclusion: { in: TERMS }
  validates :status, inclusion: { in: STATUSES }
  validate :bank_account_belongs_to_organization
  validate :bank_account_verified_for_funding, on: :create
  validate :amount_within_available_credit, on: :create

  scope :recent_first, -> { order(created_at: :desc) }

  # Operations approves after risk review; creates instalments and debits availability.
  def approve_and_fund!
    errors.clear
    unless status == "processing"
      errors.add(:status, "must be processing to fund")
      return false
    end

    transaction do
      organization.with_lock do
        organization.reload
        if organization.available_cents < amount_cents
          errors.add(:amount_cents, "exceeds available credit")
          raise ActiveRecord::Rollback
        end

        create_installment_schedule!
        update!(status: "funded", funded_at: Time.current, decline_reason: nil)
        organization.update!(available_cents: organization.available_cents - amount_cents)
      end
    end

    errors.empty? && status == "funded"
  end

  def decline!(reason:)
    errors.clear
    unless status == "processing"
      errors.add(:status, "must be processing to decline")
      return false
    end

    update!(
      status: "declined",
      decline_reason: reason.presence || "Declined by operations.",
      funded_at: nil
    )
    true
  end

  def public_code
    organization.public_draw_code(self)
  end

  private

  def amount_within_available_credit
    return if organization.blank? || amount_cents.blank?

    errors.add(:amount_cents, "exceeds available credit") if amount_cents > organization.available_cents
  end

  def bank_account_belongs_to_organization
    return if bank_account_id.blank?

    if bank_account&.organization_id != organization_id
      errors.add(:bank_account, "must belong to your organization")
    end
  end

  def bank_account_verified_for_funding
    return if bank_account_id.blank?

    errors.add(:bank_account, "must be verified") unless bank_account&.verified?
  end

  def create_installment_schedule!
    n = term_months
    total = amount_cents
    base = total / n
    remainder = total % n

    n.times do |i|
      seq = i + 1
      principal = base + (i < remainder ? 1 : 0)
      Installment.create!(
        draw: self,
        sequence: seq,
        due_on: Date.current + seq.months,
        amount_cents: principal,
        principal_cents: principal,
        interest_cents: 0,
        status: "scheduled"
      )
    end
  end
end
