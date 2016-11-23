class AddDiscussionToGrantSubmissions < ActiveRecord::Migration
  def change
    add_column :grant_submissions, :questions, :string
    add_column :grant_submissions, :answers, :string
    add_column :grant_submissions, :questions_updated_at, :datetime
    add_column :grant_submissions, :answers_updated_at, :datetime
  end
end
