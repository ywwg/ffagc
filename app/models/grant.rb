class Grant < ActiveRecord::Base
  validates :name, :presence => true
  validates :max_funding_dollars, :presence => true, :numericality => {:greater_than => 0, :less_than => 10000, :only_integer => true}
  validates :start, :presence => true
  validates :end, :presence => true
end
