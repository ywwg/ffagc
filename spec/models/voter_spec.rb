describe Voter do
  subject { FactoryBot.build(:voter) }

  include_examples 'activatable model'
  include_examples 'password reset model', 'voters'
end
