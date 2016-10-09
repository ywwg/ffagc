class AddResetToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :reset_digest, :string
    add_column :artists, :reset_sent_at, :datetime
  end
end
