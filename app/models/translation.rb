class Translation < ActiveRecord::Base
  attr_accessor :locale, :key, :value

  validates :key, :presence => true
end
