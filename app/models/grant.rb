class Grant < ActiveRecord::Base
  validates :name, :presence => true
  validates :max_funding_dollars, :presence => true, :numericality => {:greater_than => 0, :less_than => 10000, :only_integer => true}
  validates :submit_start, :presence => true
  validates :submit_end, :presence => true
  validates :vote_start, :presence => true
  validates :vote_end, :presence => true
end
