describe VotersController do
  subject { response }

  describe '#index' do
    def go!
      get 'index'
    end

    it { go!; is_expected.to be_forbidden }

    context 'with admin signed in' do
      let!(:admin) { FactoryGirl.create(:admin) }

      before { sign_in admin }

      it { go!; is_expected.to be_ok }
    end
  end

  describe '#new' do
    it 'returns ok' do
      get 'new'
      expect(response).to be_ok
    end
  end

  describe '#show' do
    let!(:voter) { FactoryGirl.create(:voter, :activated) }

    def go!(id)
      get :show, id: id
    end

    context 'with activated voter' do
      before do
        sign_in voter
      end

      it { go! voter.id; is_expected.to be_ok }

      context 'for another voter' do
        let!(:another_voter) { FactoryGirl.create(:voter) }

        it { go! another_voter.id; is_expected.to be_forbidden }
      end
    end

    context 'with user who cannot a voter' do
      let!(:user) { FactoryGirl.create(:artist) }

      before do
        sign_in user
      end

      it { go! voter.id; is_expected.to be_forbidden }
    end
  end

  describe '#create' do
    let(:voter_params) { FactoryGirl.attributes_for(:voter) }
    let(:voter_survey_attributes) { FactoryGirl.attributes_for(:voter_survey) }
    let(:grants_voter) { FactoryGirl.attributes_for(:grants_voter) }
    let(:params) do
      {
        voter: voter_params.merge(voter_survey_attributes: voter_survey_attributes),
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

    it 'creates a VoterSurvey' do
      expect { go! }.to change(VoterSurvey, :count).by(1)
    end

    context 'with existing voter email' do
      let!(:existing_voter) { FactoryGirl.create(:voter, :activated) }

      it 'returns an error' do
        post 'create', voter: { email: existing_voter.email }
        expect(response).to render_template('new')
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

      it { go!; is_expected.to be_forbidden }
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
