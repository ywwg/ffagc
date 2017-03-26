module PasswordReset
  extend ActiveSupport::Concern

  included do
    attr_accessor :reset_token

    # Sets the password reset attributes.
    def create_reset_digest
      self.reset_token = ApplicationController.new_token
      update_attribute(:reset_digest,  ApplicationController.digest(reset_token))
      update_attribute(:reset_sent_at, Time.zone.now)
    end

    # Sends password reset email.
    def send_password_reset_email
      UserMailer.password_reset(self.class.name.to_s.downcase.pluralize, self).deliver
      logger.info "email: admin password reset sent to #{self.email}"
    end

    # Returns true if a password reset has expired.
    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end
  end
end
