class Artist < ActiveRecord::Base
  include Activatable
  include PasswordReset

  has_secure_password

  has_one :artist_survey
  has_many :grant_submissions

  validates :name, presence: true, length: { minimum: 4 }
  validates :email, presence: true
  validates :password, length: { minimum: 4 }, on: :create
  validates :contact_country, inclusion: ISO3166::Country.codes

  validates_confirmation_of :password, on: :create

  def country_name
    country = ISO3166::Country[contact_country]
    country&.translations[I18n.locale.to_s] || country.name
  end
end
