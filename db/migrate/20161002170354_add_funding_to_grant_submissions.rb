class AddFundingToGrantSubmissions < ActiveRecord::Migration
  def change
    add_column :grant_submissions, :granted_funding_dollars, :integer
    add_column :grant_submissions, :funded, :boolean
  end
end
