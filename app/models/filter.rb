class Filter < ActiveRecord::Base
  has_many :rules
  accepts_nested_attributes_for :rules, :reject_if => lambda {|a| a[:substance].blank?}, :allow_destroy => true

  has_many :actions
  accepts_nested_attributes_for :actions, :reject_if => lambda {|a| a[:operation].blank?}, :allow_destroy => true

  def contents
    [rules.first.contents, actions.first.contents]
  end

  def action_to_s
    actions.first.destination
  end

  def rule_to_s
    rule = rules.first
    ret = "^"
    ret += rule.section
    ret += ":"
    ret += ".*" if rule.part == "contains" or rule.part == "ends with"
    ret += " " if rule.part == "is" or rule.part == "begins with"
    ret += rule.substance
    ret += "$" if rule.part == "is" or rule.part == "ends with"
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

