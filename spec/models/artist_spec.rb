describe Artist do
  subject { FactoryGirl.build(:artist) }

  include_examples 'activatable model'
  include_examples 'password reset model', 'artists'
end
