class Grant < ActiveRecord::Base
  has_many :grants_voters
  has_many :grant_submissions

  has_many :voters, through: :grants_voters

  validates :name, presence: true
  validates :max_funding_dollars, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :submit_start, presence: true
  validates :submit_end, presence: true
  validates :vote_start, presence: true
  validates :vote_end, presence: true
  validates :meeting_one, presence: true
  validates :meeting_two, presence: true
  # Currently the only place the "hidden" attribute is used is in the voter
  # signup page.  The intent is that some grants may be private and only voted
  # on by the Art Core.  Admins should modify individual voters to add them
  # to hidden grants.

  scope :voting_active, -> (now, timezone_string) do
    where("vote_start <= datetime(?, ?)", now, timezone_string).where("vote_end >= datetime(?, ?)", now, timezone_string)
  end

  scope :submission_active, -> (now, deadline, timezone_string) do
    where("submit_start <= datetime(?, ?)", now, timezone_string).where("submit_end >= datetime(?, ?)", deadline, timezone_string)
  end

  validate :dates_ordering

  private

  def dates_ordering
    validate_date_order(submit_start, submit_end, :submit_start, 'must be after submission end date')
    validate_date_order(vote_start, vote_end, :vote_start, 'must be after vote end date')
    validate_date_order(meeting_one, vote_end, :meeting_one, 'must be before vote end date')
    validate_date_order(meeting_two, vote_end, :meeting_two, 'must be before vote end date')
    validate_date_order(meeting_one, meeting_two, :meeting_one, 'must be before second meeting')
  end

  def validate_date_order(first_date, second_date, error_key, error_message)
    return if second_date > first_date
    errors.add(error_key, error_message)
  end
end
