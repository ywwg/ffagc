class AddDatesToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :start, :datetime
    add_column :grants, :end, :datetime
  end
end
