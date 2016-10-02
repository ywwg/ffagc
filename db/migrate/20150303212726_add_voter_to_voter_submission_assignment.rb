class AddVoterToVoterSubmissionAssignment < ActiveRecord::Migration
  def change
    add_reference :voter_submission_assignments, :voter
  end
end
