# frozen_string_literal: true

class Installment < ApplicationRecord
  belongs_to :draw

  STATUSES = %w[scheduled paid].freeze

  validates :sequence, presence: true, uniqueness: { scope: :draw_id }
  validates :due_on, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }
  validates :principal_cents, numericality: { greater_than: 0 }
  validates :interest_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }

  scope :due_first, -> { order(:due_on, :sequence) }
end
