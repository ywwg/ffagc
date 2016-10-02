class AddVoterToVote < ActiveRecord::Migration
  def change
    add_reference :votes, :voter_id
  end
end
