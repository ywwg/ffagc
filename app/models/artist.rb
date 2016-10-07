class Artist < ActiveRecord::Base
  attr_accessor :activation_token
  before_create :create_activation_digest
  
  has_secure_password

  validates :name, :presence => true, length: { minimum: 4 }
  validates :email, :presence => true
  validates :password, :length => { :minimum => 4 }, :on => :create

  validates_confirmation_of :password, :on => :create
  
  private

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = ApplicationController.new_token
    self.activation_digest = ApplicationController.digest(activation_token)
  end
  
end
