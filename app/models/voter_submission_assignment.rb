class VoterSubmissionAssignment < ActiveRecord::Base
  belongs_to :voter
  belongs_to :grant_submission
end
