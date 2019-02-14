describe Proposal do
  subject { FactoryBot.build(:proposal) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
