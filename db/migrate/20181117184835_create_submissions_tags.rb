class CreateSubmissionsTags < ActiveRecord::Migration
  def change
    create_table :submissions_tags do |t|
      t.references :tag, index: true, foreign_key: true
      t.references :grant_submissions, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
