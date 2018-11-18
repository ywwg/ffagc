class CreateSubmissionTags < ActiveRecord::Migration
  def change
    create_table :submission_tags do |t|
      t.references :tag, index: true, foreign_key: true
      t.references :grant_submission, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
