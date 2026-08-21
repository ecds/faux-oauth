# frozen_string_literal: true

#
# This app has no background job worker (ActiveJob falls back to the
# in-process :async adapter, which can silently drop jobs on container
# restarts), so mail is sent synchronously instead of via deliver_later.
# Delivery failures are logged rather than raised, so a transient SES issue
# doesn't turn an account action into a 500 — the person can still use the
# resend/retry flows we already have.
module MailerDeliverable
  extend ActiveSupport::Concern

  private

  def deliver_now_safely(mail)
    mail.deliver_now
  rescue StandardError => e
    Rails.logger.error("Mail delivery failed: #{e.class}: #{e.message}")
  end
end
