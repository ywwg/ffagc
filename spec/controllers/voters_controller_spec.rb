describe VotersController do
  describe '#signup' do
    it 'returns ok' do
      get 'signup'
      expect(response).to be_ok
    end
  end

  describe '#create' do
    let(:voter_params) { FactoryGirl.attributes_for(:voter) }
    let(:voter_survey_params) { FactoryGirl.attributes_for(:voter_survey) }
    let(:grants_voter) { FactoryGirl.attributes_for(:grants_voter) }
    let(:params) do
      {
        voter: voter_params,
        survey: voter_survey_params,
        grants_voters: [grants_voter]
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
        post 'create', voter: { email: existing_voter.email }
        expect(response).to render_template('signup_failure')
      end
    end
  end

  describe '#index' do
    context 'with activated voter' do
      let!(:voter) { FactoryGirl.create(:voter, :activated) }

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

      it 'redirects with flash' do
        get 'index'
        expect(response).to redirect_to('/')
        expect(flash).not_to be_empty
      end
    end
  end

  describe '#update' do
    let!(:voter) { FactoryGirl.create(:voter) }
    let!(:grant_1) { FactoryGirl.create(:grant) }
    let!(:grant_2) { FactoryGirl.create(:grant) }

    let(:grants_voters_params) do
      [
        [grant_1.id, '0'],
        [grant_2.id, '1']
      ]
    end

    def go!
      put 'update', id: voter.id, grants_voters: grants_voters_params
    end

    before do
      sign_in user
    end

    context 'when voter signed in' do
      let!(:user) { FactoryGirl.create(:voter) }

      it 'redirects to root' do
        go!
        expect(response).to redirect_to('/')
      end
    end

    context 'when admin logged in' do
      let!(:user) { FactoryGirl.create(:admin) }

      it 'creates new grants_voters' do
        go!
        expect(GrantsVoter.where(grant: grant_2, voter: voter)).to exist
      end

      context 'with existing grants_voter' do
        let!(:grants_voter) { FactoryGirl.create(:grants_voter, grant_id: 1, voter: voter) }

        it 'deletes' do
          go!
          expect(GrantsVoter.where(id: grants_voter.id)).not_to exist
        end
      end
    end
  end
end
