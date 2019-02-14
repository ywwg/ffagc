describe VoterSurvey do
  subject { FactoryBot.build(:voter_survey) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
