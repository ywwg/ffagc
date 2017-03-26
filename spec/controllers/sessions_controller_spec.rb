describe SessionsController do
  describe '#create_artist' do
    let!(:artist) { FactoryGirl.create(:artist, :activated) }

    it 'allows logging in with case-insensitive email' do
      post 'create_artist', { session: { email: artist.email.upcase, password: artist.password } }
      expect(response).to redirect_to('/artists')
    end

    context 'with inactive artist' do
      let!(:inactive_artist) { FactoryGirl.create(:artist) }

      it 'redirects to account activation' do
        post 'create_artist', { session: { email: inactive_artist.email, password: inactive_artist.password } }
        expect(response).to redirect_to(account_activations_unactivated_path(email: inactive_artist.email, type: 'artists'))
      end
    end
  end

  describe '#create_voter' do
    let!(:voter) { FactoryGirl.create(:voter, :activated) }

    it 'allows logging in with case-insensitive email' do
      post 'create_voter', { session: { email: voter.email.upcase, password: voter.password } }
      expect(response).to redirect_to('/voters')
    end

    context 'with inactive voter' do
      let!(:inactive_voter) { FactoryGirl.create(:voter) }

      it 'redirects to account activation' do
        post 'create_voter', { session: { email: inactive_voter.email, password: inactive_voter.password } }
        expect(response).to redirect_to(account_activations_unactivated_path(email: inactive_voter.email, type: 'voters'))
      end
    end
  end

  describe '#create_admin' do
    let!(:admin) { FactoryGirl.create(:admin, :activated) }

    it 'allows logging in with case-insensitive email' do
      post 'create_admin', { session: { email: admin.email.upcase, password: admin.password } }
      expect(response).to redirect_to('/admins')
    end

    context 'with inactive admin' do
      let!(:inactive_admin) { FactoryGirl.create(:admin) }

      it 'redirects to account activation' do
        post 'create_admin', { session: { email: inactive_admin.email, password: inactive_admin.password } }
        expect(response).to redirect_to(account_activations_unactivated_path(email: inactive_admin.email, type: 'admins'))
      end
    end
  end
end
