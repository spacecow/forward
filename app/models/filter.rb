class Filter < ActiveRecord::Base
  has_many :rules
  accepts_nested_attributes_for :rules, :reject_if => lambda {|a| a[:substance].blank?}, :allow_destroy => true

  has_many :actions
  accepts_nested_attributes_for :actions, :reject_if => lambda {|a| a[:operation].blank?}, :allow_destroy => true

  def contents
    [rules.first.contents, actions.first.contents]
  end

  def rule_to_s
    ret = ""
    ret += rules.first.section
    ret += ":"
    ret += ".*"
    ret += substance
    ret += ".*"
    ret
  end
end


# == Schema Information
#
# Table name: filters
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

