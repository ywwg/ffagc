class SubmissionTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :grant_submission
end
