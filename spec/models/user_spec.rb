describe User do
  subject { FactoryGirl.create(:user) }

  # smoke test
  it { is_expected.to be_valid }
end
