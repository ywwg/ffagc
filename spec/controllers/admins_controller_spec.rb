describe AdminsController do
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

      before { sign_in_admin(admin.id) }

      # copied as-is from existing tests, needs to be reworked
      it 'matches expectations' do
        go!
        assert_redirected_to '/admins'

        # Make sure each submission has the expected number of assigned voters
        GrantSubmission.all.each do |gs|
          vsas = VoterSubmissionAssignment.where(grant_submission_id: gs.id)

          if gs.grant == grant_2
            expect(vsas.count).to eq(2)
          else
            expect(vsas.count).to eq(3)
          end

          verify_assignments(gs.id)
        end

        # Make sure there are no dupe assignments
        Voter.all.each do |v|
          vsas_ids = VoterSubmissionAssignment.where(voter_id: v.id).pluck(:id)
          expect(vsas_ids).to eq(vsas_ids.uniq)
        end

        # Make sure voters have an even number of assignments
        # Urmam will have 4 or 5
        vsas = VoterSubmissionAssignment.where(voter_id: 1)
        expect(vsas.count).to be_between(4, 5)

        # ids 2 through 5 are inactive so they have none
        Voter.where("id >= 2 AND id <= 5").each do |v|
          vsas = VoterSubmissionAssignment.where(voter_id: v.id)
          expect(vsas.count).to eq(0)
        end

        # ids 6 and 7 will have a ton because they can vote in the second batch
        Voter.where("id >= 6 AND id <= 7").each do |v|
          vsas = VoterSubmissionAssignment.where(voter_id: v.id)
          expect(vsas.count).to be_between(14, 15)
        end

        # the rest will have 4 or 5
        Voter.where("id >= 8").each do |v|
          vsas = VoterSubmissionAssignment.where(voter_id: v.id)
          expect(vsas.count).to be_between(4, 5)
        end
      end
    end
  end

  # verify that the voters assigned to the submission can participate and are verified
  def verify_assignments(submission_id)
    submission = GrantSubmission.find(submission_id)
    grant = Grant.find(submission.grant_id)
    VoterSubmissionAssignment.where(grant_submission_id: submission.id).each do |vsa|
      voter = Voter.find(vsa.voter_id)
      assert voter.verified
      grants_voter = GrantsVoter.where(
        grant_id: submission.grant_id,
        voter_id: voter.id
      ).take
      expect(grants_voter).not_to be_nil
    end
  end
end
