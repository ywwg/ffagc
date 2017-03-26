describe Vote do
  subject { FactoryGirl.build(:vote) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
