class User < ActiveRecord::Base
  has_many :PoopLogs
  has_many :PppIndices
end
