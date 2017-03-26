class Voter < ActiveRecord::Base
  include Activatable
  include PasswordReset

  has_secure_password

  has_many :grants_voters
  has_many :votes

  validates :name, :presence => true, length: { minimum: 4 }
  validates :email, :presence => true
  validates :password, :length => { :minimum => 4 }, :on => :create

  validates_confirmation_of :password, :on => :create
end
