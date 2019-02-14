describe VotesController do
  subject { response }

  describe '#index' do
    context 'with activated and verified voter' do
      let!(:voter) { FactoryBot.create(:voter, :activated, :verified) }

      before do
        sign_in voter
      end

      it 'shows index template' do
        get 'index'
        assert_template 'index'
      end
    end

    context 'with user who cannot vote' do
      let!(:user) { FactoryBot.create(:artist) }

      before do
        sign_in user
      end

      it { get 'index'; expect(response).to be_forbidden }
    end

    context 'with admin signed in' do
      let!(:admin) { FactoryBot.create(:admin) }

      before { sign_in admin }

      it { get 'index'; is_expected.to be_forbidden }
    end
  end
end
