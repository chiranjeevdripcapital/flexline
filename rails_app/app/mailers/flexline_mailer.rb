# frozen_string_literal: true

class FlexlineMailer < ApplicationMailer
  def draw_submitted(draw)
    @draw = draw
    @organization = draw.organization
    mail to: notification_recipient!(@organization), subject: "Flexline: draw request received (#{draw.public_code})"
  end

  def draw_funded(draw)
    @draw = draw
    @organization = draw.organization
    mail to: notification_recipient!(@organization), subject: "Flexline: draw funded (#{draw.public_code})"
  end

  def draw_declined(draw)
    @draw = draw
    @organization = draw.organization
    mail to: notification_recipient!(@organization), subject: "Flexline: draw update (#{draw.public_code})"
  end

  def bank_account_ownership_verified(bank_account)
    @bank_account = bank_account
    @organization = bank_account.organization
    mail to: notification_recipient!(@organization), subject: "Flexline: sign ACH authorization to finish bank setup"
  end

  def bank_account_ready_for_draws(bank_account)
    @bank_account = bank_account
    @organization = bank_account.organization
    mail to: notification_recipient!(@organization), subject: "Flexline: bank account ready for draws"
  end

  private

  def notification_recipient!(organization)
    organization.users.order(:id).pick(:email).tap do |email|
      raise ArgumentError, "No portal users for organization #{organization.id}" if email.blank?
    end
  end
end
