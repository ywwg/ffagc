describe AdminsController do
  subject { response }

  describe '#index' do
    def go!
      get :index
    end

    context 'with valid params' do
      let(:admin_params) { FactoryGirl.attributes_for(:admin) }

      it 'creates Admin' do
        expect { go! }.to change { Admin.count }.by(1)
        expect(response).to redirect_to(root_path)
      end

      context 'when an Admin already exists' do
        let!(:admin) { FactoryGirl.create(:admin) }

        it { go!; is_expected.to be_forbidden}

        context 'when admin signed in' do
          before do
            sign_in admin
          end

          it 'creates Admin' do
            expect { go! }.to change { Admin.count }.by(1)
            expect(response).to render_template('new')
            expect(flash.keys).to include('success')
          end
        end
      end
    end
  end

  describe '#new' do
    def go!
      get :new
    end

    before { go! }

    it { is_expected.to render_template('new') }
  end

  describe '#create' do
    def go!
      post :create, admin: admin_params
    end

    let(:admin_params) { FactoryGirl.attributes_for(:admin) }

    it 'creates Admin' do
      expect { go! }.to change { Admin.count }.by(1)
      expect(response).to redirect_to(root_path)
    end

    context 'when an Admin already exists' do
      let!(:admin) { FactoryGirl.create(:admin) }

      it { go!; is_expected.to be_forbidden}

      context 'when admin signed in' do
        before do
          sign_in admin
        end

        it 'creates Admin' do
          expect { go! }.to change { Admin.count }.by(1)
          expect(response).to render_template('new')
          expect(flash.keys).to include('success')
        end
      end
    end

    context 'with invalid params' do
      let!(:existing_admin) { FactoryGirl.create(:admin) }
      let(:admin_params) { FactoryGirl.attributes_for(:admin, email: existing_admin.email) }

      it 'displays form' do
        expect { go! }.not_to change { Admin.count }
        expect(response).to render_template('new')
      end
    end
  end

  describe '#assign' do
    def go!
      post 'assign'
    end

    context 'logged out' do
      it 'redirects' do
        go!
        expect(response).to redirect_to('/')
      end
    end

    context 'logged in' do
      let!(:admin) { FactoryGirl.create(:admin, :activated) }
      let!(:grant) { FactoryGirl.create(:grant) }
      let!(:grant_2) { FactoryGirl.create(:grant) }

      before do
        FactoryGirl.create_list(:grant_submission, 16, funding_decision: false, grant: grant)
        FactoryGirl.create_list(:grant_submission, 10, funding_decision: false, grant: grant_2)

        FactoryGirl.create(:voter, :activated)
        FactoryGirl.create_list(:voter, 4, :activated, verified: false)
        FactoryGirl.create_list(:voter, 10, :activated)

        # assign to first grant
        15.times do |n|
          FactoryGirl.create(:grants_voter, voter: Voter.find(n + 1), grant: grant)
        end

        # assign to second grant
        2.times do |n|
          FactoryGirl.create(:grants_voter, voter: Voter.find(n + 6), grant: grant_2)
        end
      end

      before do
        sign_in_admin(admin.id)
        go!
      end

      it 'is redirected' do
        expect(response).to redirect_to('/admins')
      end

      it 'assigns expected number of voters to each submission' do
        GrantSubmission.all.each do |gs|
          vsas = VoterSubmissionAssignment.where(grant_submission_id: gs.id)

          if gs.grant == grant_2
            expect(vsas.count).to eq(2)
          else
            expect(vsas.count).to eq(3)
          end

          verify_assignments(gs)
        end
      end

      it 'has no duplicate assignments' do
        Voter.all.each do |v|
          vsas_ids = VoterSubmissionAssignment.where(voter_id: v.id).pluck(:id)
          expect(vsas_ids).to eq(vsas_ids.uniq)
        end
      end

      it 'assigns 4 or 5 submissions to the first voter' do
        expect(VoterSubmissionAssignment.where(voter_id: 1).count).to be_between(4, 5)
      end

      it 'does not assign submissions to inactive voters' do
        Voter.where('id >= 2 AND id <= 5').each do |v|
          expect(VoterSubmissionAssignment.where(voter_id: v.id).count).to eq(0)
        end
      end

      it 'assigns first batch voters 4 or 5 submissions each' do
        Voter.where('id >= 8').each do |v|
          expect(VoterSubmissionAssignment.where(voter_id: v.id).count).to be_between(4, 5)
        end
      end

      it 'assigns more to voters active in second batch' do
        Voter.where('id >= 6 AND id <= 7').each do |v|
          expect(VoterSubmissionAssignment.where(voter_id: v.id).count).to be_between(14, 15)
        end
      end
    end
  end

  # verify that the voters assigned to the submission can participate and are verified
  def verify_assignments(submission)
    submission.voter_submission_assignments.each do |vsa|
      grants_voter_count = GrantsVoter.where(grant: submission.grant, voter: vsa.voter).count

      expect(vsa.voter).to be_verified
      expect(grants_voter_count).not_to eq(0)
    end
  end
end
