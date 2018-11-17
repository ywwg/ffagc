class Tag < ActiveRecord::Base
  has_many :submissions_tag
end
