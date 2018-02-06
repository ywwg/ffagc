describe VotesController do
  subject { response }

  describe '#index' do
    context 'with activated and verified voter' do
      let!(:voter) { FactoryGirl.create(:voter, :activated, :verified) }

      before do
        sign_in voter
      end

      it 'shows index template' do
        get 'index'
        assert_template 'index'
      end
    end

    context 'with user who cannot vote' do
      let!(:user) { FactoryGirl.create(:artist) }

      before do
        sign_in user
      end

      it { get 'index'; expect(response).to be_forbidden }
    end
  end
end
