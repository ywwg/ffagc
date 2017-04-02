describe Sessions::ArtistsController do
  let!(:user) { FactoryGirl.create(:artist, :activated) }
  let!(:inactive_user) { FactoryGirl.create(:artist) }

  describe '#new' do
    it_behaves_like 'sessions new endpoind'
  end

  describe '#create' do
    it_behaves_like 'sessions create endpoind', 'artists', 'artist_id', '/grant_submissions'
  end

  describe '#destroy' do
    it_behaves_like 'sessions destroy endpoind', 'artist_id', '/'
  end
end
