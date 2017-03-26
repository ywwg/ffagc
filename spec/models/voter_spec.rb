describe Voter do
  subject { FactoryGirl.build(:voter) }

  include_examples 'activatable model'
end
