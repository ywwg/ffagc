describe Ability do
  subject(:ability) { Ability.new(user) }

  context 'with nil' do
    let(:user) { nil }

    it { is_expected.to be_able_to(:manage, Admin) }

    context 'an Admin already exists' do
      let!(:admin) { FactoryGirl.create(:admin) }

      it { is_expected.not_to be_able_to(:manage, Admin) }
    end
  end

  context 'with admin' do
    let(:user) { FactoryGirl.create(:admin) }

    it { is_expected.to be_able_to(:manage, Admin.new) }
    it { is_expected.to be_able_to(:manage, ArtistSurvey.new) }
    it { is_expected.to be_able_to(:manage, Artist.new) }
    it { is_expected.to be_able_to(:manage, GrantSubmission.new) }
    it { is_expected.to be_able_to(:manage, Grant.new) }
    it { is_expected.to be_able_to(:manage, GrantsVoter.new) }
    it { is_expected.to be_able_to(:manage, Proposal.new) }
    it { is_expected.to be_able_to(:manage, VoterSubmissionAssignment.new) }
    it { is_expected.to be_able_to(:manage, VoterSurvey.new) }
    it { is_expected.to be_able_to(:manage, Voter.new) }
    it { is_expected.to be_able_to(:manage, Vote.new) }
  end

  context 'with artist' do
    let!(:admin) { FactoryGirl.create(:admin) }
    let!(:user) { FactoryGirl.create(:artist, :activated) }
    let!(:artist_survey) { FactoryGirl.create(:artist_survey, artist: user) }
    let!(:grant_submission) { FactoryGirl.create(:grant_submission, artist: user) }
    let!(:proposal) { FactoryGirl.create(:proposal, grant_submission: grant_submission) }

    it { is_expected.to be_able_to(:manage, artist_survey) }
    it { is_expected.to be_able_to(:manage, grant_submission) }
    it { is_expected.to be_able_to(:manage, proposal) }
    it { is_expected.to be_able_to(:index, Grant.new) }
    it { is_expected.to be_able_to(:show, Grant.new) }

    it { is_expected.not_to be_able_to(:manage, Admin.new) }
    it { is_expected.not_to be_able_to(:manage, ArtistSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Artist.new) }
    it { is_expected.not_to be_able_to(:manage, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:manage, Grant.new) }
    it { is_expected.not_to be_able_to(:manage, GrantsVoter.new) }
    it { is_expected.not_to be_able_to(:manage, Proposal.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSubmissionAssignment.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Voter.new) }
    it { is_expected.not_to be_able_to(:manage, Vote.new) }

    context 'when not activated' do
      let!(:user) { FactoryGirl.create(:artist) }

      it { is_expected.not_to be_able_to(:manage, artist_survey) }
      it { is_expected.not_to be_able_to(:manage, grant_submission) }
      it { is_expected.not_to be_able_to(:manage, proposal) }
      it { is_expected.not_to be_able_to(:index, Grant.new) }
      it { is_expected.not_to be_able_to(:show, Grant.new) }
    end
  end

  context 'with voter' do
    let(:user) { FactoryGirl.create(:voter, :activated) }

    let(:voter_submission_assignment) { FactoryGirl.build(:voter_submission_assignment, voter: user) }
    let(:voter_survey) { FactoryGirl.create(:voter_survey, voter: user) }
    let(:vote) { FactoryGirl.build(:vote, voter: user) }

    it { is_expected.to be_able_to(:vote, GrantSubmission.new) }

    it { is_expected.to be_able_to(:manage, vote) }
    it { is_expected.to be_able_to(:manage, voter_survey) }
    it { is_expected.to be_able_to(:read, voter_submission_assignment) }
    it { is_expected.to be_able_to(:read, GrantSubmission.new) }
    it { is_expected.to be_able_to(:index, Grant.new) }
    it { is_expected.to be_able_to(:show, Grant.new) }

    it { is_expected.not_to be_able_to(:manage, Admin.new) }
    it { is_expected.not_to be_able_to(:manage, ArtistSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Artist.new) }
    it { is_expected.not_to be_able_to(:manage, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:manage, Grant.new) }
    it { is_expected.not_to be_able_to(:manage, GrantsVoter.new) }
    it { is_expected.not_to be_able_to(:manage, Proposal.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSubmissionAssignment.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Voter.new) }
    it { is_expected.not_to be_able_to(:manage, Vote.new) }

    context 'when not activated' do
      let(:user) { FactoryGirl.create(:voter) }

      it { is_expected.not_to be_able_to(:vote, GrantSubmission.new) }

      it { is_expected.not_to be_able_to(:manage, vote) }
      it { is_expected.not_to be_able_to(:manage, voter_survey) }
      it { is_expected.not_to be_able_to(:read, voter_submission_assignment) }
      it { is_expected.not_to be_able_to(:read, GrantSubmission.new) }
      it { is_expected.not_to be_able_to(:index, Grant.new) }
      it { is_expected.not_to be_able_to(:show, Grant.new) }
    end
  end
end
