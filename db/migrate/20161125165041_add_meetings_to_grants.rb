class AddMeetingsToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :meeting_one, :datetime
    add_column :grants, :meeting_two, :datetime
  end
end
