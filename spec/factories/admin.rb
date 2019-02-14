FactoryBot.define do
  factory :admin do
    name { Faker::Name.name }
    email
    password { Faker::Internet.password }

    trait :activated do
      activated { true }
      activated_at { Time.now }
    end
  end
end
