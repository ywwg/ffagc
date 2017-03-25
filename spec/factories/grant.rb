FactoryGirl.define do
  factory :grant do
    name { Faker::Hipster.sentence }
    hidden false
    max_funding_dollars { 5_000 }
    submit_start { Date.today }
    submit_end { 1.week.from_now }
    vote_start { 1.week.from_now }
    vote_end { 4.weeks.from_now }
    meeting_one { 2.weeks.from_now }
    meeting_two { 3.weeks.from_now }
  end
end
