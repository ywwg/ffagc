class AddVoterToVote < ActiveRecord::Migration
  def change
    add_reference :votes, :voter
  end
end
