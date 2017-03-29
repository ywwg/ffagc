describe Proposal do
  subject { FactoryGirl.build(:proposal) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
