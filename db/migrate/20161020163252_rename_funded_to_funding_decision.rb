class RenameFundedToFundingDecision < ActiveRecord::Migration
  def change
    rename_column :grant_submissions, :funded, :funding_decision
  end
end
