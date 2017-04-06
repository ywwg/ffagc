FactoryGirl.define do
  factory :grant_submission do
    name { Faker::Hipster.sentence }
    description { Faker::Hipster.sentence }
    grant
    artist
    requested_funding_dollars { 1_000 }

    trait :funded do
      funding_decision true
      granted_funding_dollars 1
    end
  end
end
