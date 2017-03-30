module Activatable
  extend ActiveSupport::Concern

  included do
    before_create :create_activation_digest

    attr_accessor :activation_token

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token = ApplicationController.new_token
      self.activation_digest = ApplicationController.digest(activation_token)
    end

    def activate!
      return if activated?

      update!(
        activated: true,
        activated_at: Time.zone.now
      )
    end

    def activation_token_valid?(token)
      BCrypt::Password.new(activation_digest).is_password?(token)
    end
  end
end
