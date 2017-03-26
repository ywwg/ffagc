class Grant < ActiveRecord::Base
  has_many :grants_voters
  has_many :grant_submissions

  validates :name, presence: true
  validates :max_funding_dollars, presence: true, numericality: { greater_than: 0, only_integer: true}
  validates :submit_start,  presence: true
  validates :submit_end,  presence: true
  validates :vote_start,  presence: true
  validates :vote_end,  presence: true
  validates :meeting_one,  presence: true
  validates :meeting_two,  presence: true
  # Currently the only place the "hidden" attribute is used is in the voter
  # signup page.  The intent is that some grants may be private and only voted
  # on by the Art Core.  Admins should modify individual voters to add them
  # to hidden grants.

  validate :dates_ordering

  private

  def dates_ordering
    if submit_start > submit_end
      errors.add(:submit_start, "must be after submission end date")
    end
    if vote_start > vote_end
      errors.add(:vote_start, "must be after vote end date")
    end
    if meeting_one > vote_end
      errors.add(:meeting_one, "must be before vote end date")
    end
    if meeting_two > vote_end
      errors.add(:meeting_two, "must be before vote end date")
    end
    if meeting_one > meeting_two
      errors.add(:meeting_one, "must be before second meeting")
    end
  end
end
