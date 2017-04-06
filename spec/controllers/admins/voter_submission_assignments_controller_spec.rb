describe Admins::VoterSubmissionAssignmentsController do
  let!(:admin) { FactoryGirl.create(:admin, :activated) }

  subject { response }

  describe '#destroy' do
    def go!
      delete 'destroy'
    end

    context 'logged out' do
      it 'is forbidden' do
        go!
        expect(response).to be_forbidden
      end
    end

    context 'logged in' do
      let!(:voter_submission_assignment) { FactoryGirl.create(:voter_submission_assignment) }

      before do
        sign_in admin
      end

      it { go!; is_expected.to be_redirect }

      it 'destroys VoterSubmissionAssignments' do
        expect { go! }.to change { VoterSubmissionAssignment.count }.to 0
      end
    end
  end

  describe '#assign' do
    def go!
      post 'assign'
    end

    context 'logged out' do
      it 'is forbidden' do
        go!
        expect(response).to be_forbidden
      end
    end

    context 'logged in' do
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
        sign_in admin
        go!
      end

      it 'matches expectations' do
        expect(response).to redirect_to('/admins')

        # assigns expected number of voters to each submission
        GrantSubmission.all.each do |gs|
          vsas = VoterSubmissionAssignment.where(grant_submission_id: gs.id)

          if gs.grant == grant_2
            expect(vsas.count).to eq(2)
          else
            expect(vsas.count).to eq(3)
          end

          verify_assignments(gs)
        end

        # has no duplicate assignments
        Voter.all.each do |v|
          vsas_ids = VoterSubmissionAssignment.where(voter_id: v.id).pluck(:id)
          expect(vsas_ids).to eq(vsas_ids.uniq)
        end

        # assigns 4 or 5 submissions to the first voter
        expect(VoterSubmissionAssignment.where(voter_id: 1).count).to be_between(4, 5)

        # does not assign submissions to inactive voters
        Voter.where('id >= 2 AND id <= 5').each do |v|
          expect(VoterSubmissionAssignment.where(voter_id: v.id).count).to eq(0)
        end

        # assigns first batch voters 4 or 5 submissions each
        Voter.where('id >= 8').each do |v|
          expect(VoterSubmissionAssignment.where(voter_id: v.id).count).to be_between(4, 5)
        end

        # assigns more to voters active in second batch
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
