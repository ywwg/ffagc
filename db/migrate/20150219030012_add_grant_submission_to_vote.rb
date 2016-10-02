class AddGrantSubmissionToVote < ActiveRecord::Migration
  def change
    add_reference :votes, :grant_submission
  end
end
