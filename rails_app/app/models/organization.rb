# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :draws, dependent: :destroy

  validates :name, presence: true
  validates :credit_limit_cents, numericality: { greater_than: 0 }
  validates :available_cents, numericality: { greater_than_or_equal_to: 0 }

  validate :available_within_limit

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
