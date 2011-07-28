class Filter < ActiveRecord::Base
  has_many :rules
  accepts_nested_attributes_for :rules, :reject_if => lambda {|a| a[:substance].blank?}, :allow_destroy => true

  has_many :actions
  accepts_nested_attributes_for :actions, :reject_if => lambda {|a| a[:operation].blank?}, :allow_destroy => true
end


# == Schema Information
#
# Table name: filters
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

