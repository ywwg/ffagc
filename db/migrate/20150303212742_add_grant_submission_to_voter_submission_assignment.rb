class AddGrantSubmissionToVoterSubmissionAssignment < ActiveRecord::Migration
  def change
    add_reference :voter_submission_assignments, :grant_submission
  end
end
