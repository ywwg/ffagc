FactoryGirl.define do
  factory :grant do
    name { Faker::Hipster.sentence }
    hidden false
  end
end
