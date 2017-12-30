describe Sessions::VotersController do
  let!(:user) { FactoryGirl.create(:voter, :activated, :verified) }
  let!(:unverified_user) { FactoryGirl.create(:voter, :activated) }
  let!(:inactive_user) { FactoryGirl.create(:voter) }

  describe '#new' do
    it_behaves_like 'sessions new endpoint'
  end

  describe '#create' do
    it_behaves_like 'sessions create endpoint', 'voters', 'voter_id', '/votes'
  end

  describe '#destroy' do
    it_behaves_like 'sessions destroy endpoint', 'voter_id', '/'
  end
end
