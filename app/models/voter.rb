class Voter < ActiveRecord::Base
  include Activatable
  include PasswordReset

  has_secure_password

  has_many :grants_voters
  has_many :grants, through: :grants_voters
  has_many :votes
  has_one :voter_survey, inverse_of: :voter
  has_many :voter_submission_assignments
  has_many :grant_submissions, through: :voter_submission_assignments

  accepts_nested_attributes_for :voter_survey

  validates :name, presence: true, length: { minimum: 4 }
  validates :email, presence: true
  validates :password, length: { minimum: 4 }, on: :create

  validates_confirmation_of :password, on: :create

  def self.verified_emails
    email_list = []
    Voter.where(activated: true, verified: true).each do |v|
      email_list.push("#{v.name} <#{v.email}>")
    end
    return email_list
  end
end
