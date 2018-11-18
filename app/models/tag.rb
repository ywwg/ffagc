class Tag < ActiveRecord::Base
  has_many :submission_tag

  # Returns a list of strings for each tag on the given grant submission.
  def self.tags_for_submission(grant_submission, can_view_hidden)
    if !can_view_hidden
      Tag.joins(:submission_tag)
        .where(hidden: false,
              :submission_tags => {:grant_submission_id => grant_submission})
        .map(&:name)
    else
      Tag.joins(:submission_tag)
        .where(:submission_tags => {:grant_submission_id => grant_submission})
        .map(&:name)
    end
  end

  # Returns all of the tags, minus the hidden ones if can_view_hidden is false.
  def self.all_maybe_hidden(can_view_hidden)
    if !can_view_hidden
      Tag.where(hidden: false)
    else
      Tag.all
    end
  end
end
