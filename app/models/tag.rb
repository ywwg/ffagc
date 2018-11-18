class Tag < ActiveRecord::Base
  has_many :submission_tag
end
