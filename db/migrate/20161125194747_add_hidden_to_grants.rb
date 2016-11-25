class AddHiddenToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :hidden, :boolean, default: false
  end
end
