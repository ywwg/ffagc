class AddContactZipcodeToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :contact_zipcode, :string
  end
end
