describe VoterSubmissionAssignment do
  subject { FactoryBot.build(:voter_submission_assignment) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
