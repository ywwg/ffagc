class Voter < ActiveRecord::Base
  attr_accessor :activation_token, :reset_token
  before_create :create_activation_digest
  has_secure_password
  has_many :grants_voters
  has_many :votes

  validates :name, :presence => true, length: { minimum: 4 }
  validates :email, :presence => true
  validates :password, :length => { :minimum => 4 }, :on => :create

  validates_confirmation_of :password, :on => :create

  # These really should be private but then the password resetter can't get
  # at them

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = ApplicationController.new_token
    update_attribute(:reset_digest,  ApplicationController.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset("voters", self).deliver
    logger.info "email: voter password reset sent to #{self.email}"
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = ApplicationController.new_token
    self.activation_digest = ApplicationController.digest(activation_token)
  end
end
