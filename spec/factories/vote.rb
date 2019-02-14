FactoryBot.define do
  factory :vote do
    voter
    grant_submission
    score_t { generate :vote_score }
    score_c { generate :vote_score }
    score_f { generate :vote_score }
  end
end
