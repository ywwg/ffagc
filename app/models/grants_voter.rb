class GrantsVoter < ActiveRecord::Base
  belongs_to :voter
  belongs_to :grant
end
