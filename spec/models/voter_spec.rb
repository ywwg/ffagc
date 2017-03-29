describe Voter do
  subject { FactoryGirl.build(:voter) }

  include_examples 'activatable model'
  include_examples 'password reset model', 'voters'
end
