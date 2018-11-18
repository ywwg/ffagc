class Tag < ActiveRecord::Base
  has_many :submission_tag

  # Returns a list of strings for each tag on the given grant submission.
  def self.tags_for_submission(grant_submission)
    Tag.joins(:submission_tag).where(:submission_tags => {:grant_submission_id => grant_submission}).map(&:name)
  end
end
