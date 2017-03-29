FactoryGirl.define do
  factory :grant_submission do
    name { Faker::Hipster.sentence }
    description { Faker::Hipster.sentence }
    grant
    artist
    requested_funding_dollars { 1_000 }
  end
end
