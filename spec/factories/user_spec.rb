FactoryGirl.define do
  factory :user do
    email
    password { Faker::Internet.password }
  end
end
