class AddGrantFundingLevels < ActiveRecord::Migration
  def change
    add_column :grants, :funding_levels_csv, :string
  end
end
