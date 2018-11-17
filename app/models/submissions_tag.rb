class SubmissionsTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :grant_submissions
end
