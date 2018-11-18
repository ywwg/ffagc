class Tag < ActiveRecord::Base
  has_many :submission_tag

  # Returns all of the tags, minus the hidden ones if can_view_hidden is false.
  def self.all_maybe_hidden(can_view_hidden)
    if !can_view_hidden
      Tag.where(hidden: false)
    else
      Tag.all
    end
  end
end
