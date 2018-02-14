class Artist < ActiveRecord::Base
  include Activatable
  include PasswordReset

  has_secure_password

  has_one :artist_survey, inverse_of: :artist
  has_many :grant_submissions

  accepts_nested_attributes_for :artist_survey

  validates :name, presence: true, length: { minimum: 4 }
  validates :email, presence: true
  validates :password, length: { minimum: 4 }, on: :create
  validates :contact_country, inclusion: ISO3166::Country.codes

  validates_confirmation_of :password, on: :create

  def country_name
    country = ISO3166::Country[contact_country]
    country&.translations[I18n.locale.to_s] || country.name
  end

  def self.activated_emails
    email_list = []
    Artist.where(activated: true).each do |a|
      email_list.push("#{a.name} <#{a.email}>")
    end
    return email_list
  end

  def self.funded_emails
    email_list = []
    Artist.joins(:grant_submissions)
          .select('artists.name, artists.email')
          .where("grant_submissions.funding_decision == 't' AND grant_submissions.granted_funding_dollars || 0 > 0")
          .uniq()
          .each do |a|
      email_list.push("#{a.name} <#{a.email}>")
    end
    return email_list
  end
end
