class AddSubmissionsTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
    create_table :submissions_tags do |t|
      t.timestamps
    end
    add_reference :submissions_tags, :grant_submissions
    add_reference :submissions_tags, :tags
  end
end
