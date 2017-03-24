describe VotersController do
  describe "#signup" do
    it 'returns ok' do
      get 'signup'
      expect(response).to be_ok
    end
  end

  describe "#create" do
    let(:voter_params) { FactoryGirl.attributes_for(:voter) }
    let(:voter_survey_params) { FactoryGirl.attributes_for(:voter_survey) }
    let(:grants_voter) { FactoryGirl.attributes_for(:grants_voter) }
    let(:params) do
      {
        voter: voter_params,
        survey: voter_survey_params,
        grants_voters: [grants_voter],
      }
    end

    def go!
      post 'create', params
    end

    it 'returns ok' do
      go!
      expect(response).to be_ok
    end

    it 'creates a voter' do
      expect { go! }.to change(Voter, :count).by(1)
    end

    context 'with existing voter' do
      let!(:existing_voter) { FactoryGirl.create(:voter, :activated) }

      it 'returns an error' do
        post 'create', { voter: { email: existing_voter.email } }
        expect(response).to render_template('signup_failure')
      end
    end
  end
end
