class Grant < ActiveRecord::Base
  validates :name, :presence => true
  validates :max_funding_dollars, :presence => true, :numericality => {:greater_than => 0, :only_integer => true}
  validates :submit_start, :presence => true
  validates :submit_end, :presence => true
  validates :vote_start, :presence => true
  validates :vote_end, :presence => true
  validates :meeting_one, :presence => true
  validates :meeting_two, :presence => true

  # This is redundant to the javascript validation.
  validate :dates_ordering

  def dates_ordering
    if submit_start > submit_end
      errors.add(:submit_start, "must be after submission end date")
    end
    if vote_start > vote_end
      errors.add(:submit_start, "must be after vote end date")
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
