# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("FLEXLINE_MAILER_FROM", "Flexline <noreply@localhost>") }
  layout "mailer"
end
