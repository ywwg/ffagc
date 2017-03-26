FactoryGirl.define do
  sequence :email do |n|
    "email-#{n}@example.com"
  end

  sequence :vote_score do
    Faker::Number.between(1, 3)
  end
end

