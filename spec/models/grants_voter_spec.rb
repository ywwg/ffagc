describe GrantsVoter do
  subject { FactoryBot.build(:grants_voter) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
