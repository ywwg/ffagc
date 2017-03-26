FactoryGirl.define do
  sequence :email do |n|
    "email-#{n}@example.com"
  end

  sequence :vote_score do
    Faker::Number.between(0, 2)
  end
end

