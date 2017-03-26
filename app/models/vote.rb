class Vote < ActiveRecord::Base
  belongs_to :voter
  belongs_to :grant_submission

  # TODO add validatios for scores
end
