class Admin < ActiveRecord::Base
  include PasswordReset

  attr_accessor :activation_token

  has_secure_password

  validates :name, presence: true, length: { minimum: 4 }
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 4 }, on: :create

  validates_confirmation_of :password, on: :create

  before_validation :normalize_email, :activate

  private

  def normalize_email
    self.email = email.downcase.strip
  end

  def activate
    self.activated = true
    self.activated_at = Time.now
  end
end
