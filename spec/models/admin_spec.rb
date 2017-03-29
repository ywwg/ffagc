describe Admin do
  subject { FactoryGirl.build(:admin) }

  include_examples 'password reset model', 'admins'
end
