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
  end
end
