describe GrantsVoter do
  subject { FactoryGirl.build(:grants_voter) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
