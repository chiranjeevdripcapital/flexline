# frozen_string_literal: true

class AdminEvent < ApplicationRecord
  ACTIONS = %w[
    draw_approved
    draw_declined
    draw_operator_notes_updated
  ].freeze

  belongs_to :organization, optional: true
  belongs_to :draw, optional: true
  belongs_to :bank_account, optional: true

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :actor_identifier, presence: true

  scope :recent_first, -> { order(created_at: :desc) }

  def self.record!(action:, actor_identifier:, draw: nil, organization: nil, bank_account: nil, metadata: {})
    org = organization || draw&.organization || bank_account&.organization
    create!(
      action: action,
      actor_identifier: actor_identifier.to_s.presence || "unknown",
      organization: org,
      draw: draw,
      bank_account: bank_account || draw&.bank_account,
      metadata: metadata || {}
    )
  end
end
