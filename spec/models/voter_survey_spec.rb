describe VoterSurvey do
  subject { FactoryGirl.build(:voter_survey) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
