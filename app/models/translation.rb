class Translation < ActiveRecord::Base
  belongs_to :locale

  attr_accessible :locale_id, :key, :value

  validates_presence_of :key, :value, :locale_id
end
