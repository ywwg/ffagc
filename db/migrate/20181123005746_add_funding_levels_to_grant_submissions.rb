class AddFundingLevelsToGrantSubmissions < ActiveRecord::Migration
  def change
    add_column :grant_submissions, :funding_requests_csv, :string
  end
end
