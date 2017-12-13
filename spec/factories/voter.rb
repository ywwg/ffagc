FactoryGirl.define do
  factory :voter do
    name { Faker::Name.name }
    email
    password { Faker::Internet.password }

    trait :verified do
      verified true
    end

    trait :activated do
      activated true
    end
  end
end
