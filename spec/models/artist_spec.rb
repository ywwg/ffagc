describe Artist do
  subject { FactoryGirl.build(:artist) }

  include_examples 'activatable model'
end
