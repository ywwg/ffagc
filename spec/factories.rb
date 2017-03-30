FactoryGirl.define do
  sequence :email do |n|
    Faker::Internet.unique.email
  end

  sequence :vote_score do
    Faker::Number.between(0, 2)
  end
end
