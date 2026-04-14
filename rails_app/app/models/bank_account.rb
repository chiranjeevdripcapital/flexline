# frozen_string_literal: true

require "digest"

class BankAccount < ApplicationRecord
  belongs_to :organization
  has_many :draws, dependent: :restrict_with_error
  has_many :admin_events, dependent: :nullify
  has_many :bank_removal_requests, dependent: :destroy

  # NOTE: routing_number/account_number require encryption at rest and strict access controls before production launch.

  VERIFICATION_STATUSES = %w[
    incomplete
    awaiting_plaid
    micro_deposit_sent
    ownership_verified
    verified
    failed
    removed
  ].freeze

  VERIFICATION_METHODS = %w[plaid micro_deposit].freeze
  ACCOUNT_TYPES = %w[checking savings].freeze

  MICRO_DEPOSIT_MAX_ATTEMPTS = 3
  MICRO_DEPOSIT_EXPIRY_DAYS = 10

  validates :display_name, presence: true
  validates :legal_name_on_account, presence: true, on: :details
  validates :account_type, inclusion: { in: ACCOUNT_TYPES }
  validates :verification_method, inclusion: { in: VERIFICATION_METHODS }, on: :details
  validates :routing_number, format: { with: /\A\d{9}\z/ }, on: :details
  validates :account_number, format: { with: /\A\d{4,17}\z/ }, on: :details
  validates :mask_last4, format: { with: /\A\d{4}\z/ }
  validates :verification_status, inclusion: { in: VERIFICATION_STATUSES }
  validates :ach_authorization_signed_at, presence: { message: "must be recorded when status is fully verified" }, if: -> { verification_status == "verified" }

  validate :fingerprint_unique_within_organization, on: :details
  validate :cannot_edit_verified_core_fields, on: :update

  before_validation :normalize_bank_fields
  before_validation :set_mask_last4_from_account_number
  before_validation :assign_fingerprint, on: :details

  scope :verified, -> { where(verification_status: "verified") }
  scope :usable_for_transfers, -> { verified }

  def verified?
    verification_status == "verified"
  end

  # Plaid or micro-deposit ownership proof complete; ACH authorization letter not yet signed.
  def ownership_verified?
    verification_status == "ownership_verified"
  end

  def removed?
    verification_status == "removed"
  end

  # Called when operations approves a borrower-initiated removal (see BankRemovalRequest).
  # Caller must ensure another verified account remains before invoking.
  def apply_operator_removal!
    update!(
      verification_status: "removed",
      primary_for_disbursement: false,
      plaid_item_id: nil,
      plaid_account_id: nil,
      failure_reason: nil
    )
    organization.ensure_primary_verified_bank_account!
  end

  def plaid?
    verification_method == "plaid"
  end

  def micro_deposit?
    verification_method == "micro_deposit"
  end

  def micro_deposit_expired?
    micro_deposit? &&
      micro_deposit_sent_at.present? &&
      micro_deposit_sent_at < MICRO_DEPOSIT_EXPIRY_DAYS.days.ago &&
      !verified?
  end

  def micro_deposit_locked?
    micro_deposit_attempts >= MICRO_DEPOSIT_MAX_ATTEMPTS
  end

  # Called after Plaid Link success in production; in development can be invoked via "Simulate Plaid success".
  def complete_plaid_verification!(item_id:, account_id:)
    transaction do
      update!(
        plaid_item_id: item_id,
        plaid_account_id: account_id,
        verification_status: "ownership_verified",
        ach_authorization_signed_at: nil,
        failure_reason: nil,
        micro_deposit_sent_at: nil,
        micro_deposit_a_cents: nil,
        micro_deposit_b_cents: nil
      )
      ensure_single_primary!
    end
  end

  # Adobe eSign (or equivalent) reports signed ACH authorization — last step before draws.
  def complete_ach_authorization!
    raise "ACH can only be completed after ownership verification." unless ownership_verified?

    transaction do
      update!(
        verification_status: "verified",
        ach_authorization_signed_at: Time.current,
        failure_reason: nil
      )
      ensure_single_primary!
    end
  end

  def initiate_micro_deposits!
    raise "Finish or cancel Plaid before starting micro-deposits." if plaid? && verification_status == "awaiting_plaid"

    a = rand(1..99)
    b = rand(1..99)
    b = rand(1..99) while b == a

    update!(
      verification_method: "micro_deposit",
      verification_status: "micro_deposit_sent",
      micro_deposit_sent_at: Time.current,
      micro_deposit_a_cents: a,
      micro_deposit_b_cents: b,
      micro_deposit_attempts: 0,
      failure_reason: nil
    )
  end

  # amounts are whole cents as entered by the user (e.g., 32 for $0.32)
  def confirm_micro_deposit_amounts!(amount_a_cents:, amount_b_cents:)
    return false if plaid?
    return false if micro_deposit_locked?
    return false if micro_deposit_expired?

    ok =
      micro_deposit_a_cents.present? &&
        micro_deposit_b_cents.present? &&
        [ amount_a_cents, amount_b_cents ].sort == [ micro_deposit_a_cents, micro_deposit_b_cents ].sort

    if ok
      update!(
        verification_status: "ownership_verified",
        ach_authorization_signed_at: nil,
        failure_reason: nil
      )
      ensure_single_primary!
      true
    else
      increment!(:micro_deposit_attempts)
      reload
      attrs = { failure_reason: "Micro-deposit amounts did not match." }
      if micro_deposit_attempts >= MICRO_DEPOSIT_MAX_ATTEMPTS
        attrs[:verification_status] = "failed"
        attrs[:failure_reason] =
          "Too many incorrect attempts. Start again with a fresh verification or contact support if you need help."
      end
      update!(attrs)
      false
    end
  end

  def micro_deposit_confirmable?
    micro_deposit? &&
      verification_status == "micro_deposit_sent" &&
      !micro_deposit_locked? &&
      !micro_deposit_expired?
  end

  def restartable?
    !verified? && !ownership_verified?
  end

  def label_for_draw_select
    primary = primary_for_disbursement? ? " · Primary" : ""
    "#{display_name} · ···#{mask_last4}#{primary}"
  end

  def restart_verification!
    update!(
      verification_status: "incomplete",
      verification_method: nil,
      plaid_item_id: nil,
      plaid_account_id: nil,
      micro_deposit_sent_at: nil,
      micro_deposit_a_cents: nil,
      micro_deposit_b_cents: nil,
      micro_deposit_attempts: 0,
      failure_reason: nil,
      ach_authorization_signed_at: nil
    )
  end

  # When Plaid is unavailable (institution not listed, outage, or product not yet wired), reuse saved routing/account.
  def switch_from_plaid_to_micro!
    raise "Only available during Plaid verification." unless verification_status == "awaiting_plaid"

    transaction do
      update!(
        verification_method: "micro_deposit",
        plaid_item_id: nil,
        plaid_account_id: nil
      )
      initiate_micro_deposits!
    end
  end

  def self.fingerprint_for(routing, account)
    Digest::SHA256.hexdigest("#{routing}:#{account}")
  end

  private

  def normalize_bank_fields
    self.routing_number = routing_number.to_s.gsub(/\D/, "").presence
    self.account_number = account_number.to_s.gsub(/\D/, "").presence
  end

  def set_mask_last4_from_account_number
    return if account_number.blank?

    self.mask_last4 = account_number.last(4)
  end

  def assign_fingerprint
    return if routing_number.blank? || account_number.blank?

    self.account_fingerprint = self.class.fingerprint_for(routing_number, account_number)
  end

  def fingerprint_unique_within_organization
    return if account_fingerprint.blank?

    scope = self.class.where(organization_id: organization_id, account_fingerprint: account_fingerprint)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:base, "This bank account is already on file for your company.") if scope.exists?
  end

  def cannot_edit_verified_core_fields
    return unless persisted?
    return unless verified? || ownership_verified?

    changed_core = (changed & %w[routing_number account_number account_type legal_name_on_account]).any?
    return unless changed_core

    errors.add(:base, "Accounts that completed ownership verification cannot change core bank details here. Add a new account instead.")
  end

  def ensure_single_primary!
    return unless primary_for_disbursement?

    organization.bank_accounts.where.not(id: id).update_all(primary_for_disbursement: false)
  end
end
