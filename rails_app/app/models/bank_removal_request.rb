# frozen_string_literal: true

class BankRemovalRequest < ApplicationRecord
  STATUSES = %w[pending_review approved rejected].freeze

  belongs_to :organization
  belongs_to :bank_account

  validates :borrower_reason, presence: true, length: { minimum: 20, maximum: 5000 }
  validates :status, inclusion: { in: STATUSES }
  validate :bank_account_must_be_verified, on: :create
  validate :bank_account_must_belong_to_organization, on: :create
  validate :another_verified_account_must_remain, on: :create
  validate :no_concurrent_pending_for_same_account, on: :create

  scope :recent_first, -> { order(created_at: :desc) }
  scope :pending_review, -> { where(status: "pending_review") }

  def pending_review?
    status == "pending_review"
  end

  def approve!(reviewer:, operator_notes: nil)
    errors.clear
    return false unless pending_review?

    unless organization.bank_accounts.where(verification_status: "verified").where.not(id: bank_account_id).exists?
      errors.add(:base, "Cannot approve: the company must still have at least one other verified account.")
      return false
    end

    transaction do
      bank_account.apply_operator_removal!
      update!(
        status: "approved",
        reviewer_identifier: reviewer.to_s.presence,
        reviewed_at: Time.current,
        operator_notes: operator_notes.to_s.presence
      )
    end
    true
  rescue StandardError => e
    Rails.logger.error("[BankRemovalRequest#approve!] #{e.class}: #{e.message}")
    errors.add(:base, "Could not complete approval. Try again or check logs.")
    false
  end

  def reject!(reviewer:, operator_notes: nil)
    errors.clear
    return false unless pending_review?

    update!(
      status: "rejected",
      reviewer_identifier: reviewer.to_s.presence,
      reviewed_at: Time.current,
      operator_notes: operator_notes.to_s.presence
    )
    true
  end

  private

  def bank_account_must_be_verified
    return if bank_account.blank?

    errors.add(:bank_account, "must be verified to request removal") unless bank_account.verified?
  end

  def bank_account_must_belong_to_organization
    return if bank_account.blank? || organization.blank?

    errors.add(:bank_account, "does not belong to this organization") if bank_account.organization_id != organization_id
  end

  def another_verified_account_must_remain
    return if bank_account.blank? || organization.blank?

    others = organization.bank_accounts.where(verification_status: "verified").where.not(id: bank_account_id)
    return if others.exists?

    errors.add(:base, "You must keep at least one other verified bank account. Add and verify another account before requesting removal.")
  end

  def no_concurrent_pending_for_same_account
    return if bank_account_id.blank?

    scope = self.class.where(bank_account_id: bank_account_id, status: "pending_review")
    scope = scope.where.not(id: id) if persisted?
    errors.add(:base, "A removal request for this account is already awaiting review.") if scope.exists?
  end
end
