# frozen_string_literal: true

# Borrower-facing activity derived from existing records (no separate notifications table).
class PortalActivity
  Entry = Struct.new(:at, :headline, :detail, :amount_cents, :path, keyword_init: true)

  def self.for_organization(organization, limit: 8)
    entries = []
    organization.draws.includes(:bank_account).recent_first.limit(6).each do |d|
      entries << Entry.new(
        at: d.updated_at,
        headline: "Draw #{d.public_code}",
        detail: "#{d.status.titleize} · #{d.term_months} mo",
        amount_cents: d.amount_cents,
        path: Rails.application.routes.url_helpers.draw_request_path(d)
      )
    end

    organization.bank_accounts.verified.order(updated_at: :desc).limit(4).each do |b|
      entries << Entry.new(
        at: b.updated_at,
        headline: "Bank account verified",
        detail: "#{b.display_name} · ···#{b.mask_last4}",
        amount_cents: nil,
        path: Rails.application.routes.url_helpers.bank_account_path(b)
      )
    end

    entries.sort_by { |e| -e.at.to_i }.first(limit)
  end
end
