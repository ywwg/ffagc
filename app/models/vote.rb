class Vote < ActiveRecord::Base
  belongs_to :voter

  MIN_VOTE_SCORE = 0
  MAX_VOTE_SCORE = 2

  validates :score_t, numericality: { greater_than_or_equal_to: MIN_VOTE_SCORE, less_than_or_equal_to: MAX_VOTE_SCORE, only_integer: true, allow_nil: true }
  validates :score_c, numericality: { greater_than_or_equal_to: MIN_VOTE_SCORE, less_than_or_equal_to: MAX_VOTE_SCORE, only_integer: true, allow_nil: true }
  validates :score_f, numericality: { greater_than_or_equal_to: MIN_VOTE_SCORE, less_than_or_equal_to: MAX_VOTE_SCORE, only_integer: true, allow_nil: true }
end
