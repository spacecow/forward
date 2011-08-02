class Filter < ActiveRecord::Base
  belongs_to :user

  has_many :rules, :dependent => :destroy
  accepts_nested_attributes_for :rules, :reject_if => lambda {|a| a[:section].blank? || a[:part].blank? || a[:substance].blank?}, :allow_destroy => true

  has_many :actions, :dependent => :destroy
  accepts_nested_attributes_for :actions, :reject_if => lambda {|a| a[:operation].blank? || a[:destination].blank?}, :allow_destroy => true

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
#  user_id    :integer(4)
#

