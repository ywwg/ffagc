describe Sessions::VotersController do
  let!(:user) { FactoryGirl.create(:voter, :activated) }
  let!(:inactive_user) { FactoryGirl.create(:voter) }

  describe '#new' do
    it_behaves_like 'sessions new endpoind'
  end

  describe '#create' do
    it_behaves_like 'sessions create endpoind', 'voters', 'voter_id', '/grant_submissions'
  end

  describe '#destroy' do
    it_behaves_like 'sessions destroy endpoind', 'voter_id', '/'
  end
end
