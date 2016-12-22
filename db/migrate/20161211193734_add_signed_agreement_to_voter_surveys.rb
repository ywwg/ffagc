class AddSignedAgreementToVoterSurveys < ActiveRecord::Migration
  def change
    add_column :voter_surveys, :signed_agreement, :boolean, default: false
  end
end
