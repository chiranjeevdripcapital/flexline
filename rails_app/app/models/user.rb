# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :organization

  has_secure_password

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
