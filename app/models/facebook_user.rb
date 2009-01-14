class FacebookUser < ActiveRecord::Base
  has_many :PoopLogs
  has_many :PppIndices
end
