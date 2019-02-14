describe Sessions::VotersController do
  let!(:user) { FactoryBot.create(:voter, :activated, :verified) }
  let!(:unverified_user) { FactoryBot.create(:voter, :activated) }
  let!(:inactive_user) { FactoryBot.create(:voter) }

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
