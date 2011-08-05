class Filter < ActiveRecord::Base
  belongs_to :user

  has_many :rules, :dependent => :destroy
  accepts_nested_attributes_for :rules, :reject_if => lambda {|a| a[:section].blank? || a[:part].blank? || a[:substance].blank?}, :allow_destroy => true

  has_many :actions, :dependent => :destroy
  accepts_nested_attributes_for :actions, :reject_if => lambda {|a| a[:operation].blank? || a[:destination].blank?}, :allow_destroy => true

  validate :at_least_one_action_must_exist
  validate :at_least_one_rule_must_exist

  def contents
    [rules.first.contents, actions.first.contents]
  end

  def actions_to_file; actions.first.to_file end
  def actions_to_s; actions.first.to_s end

  def rules_contents; rules.map(&:contents) end
  def rules_to_file; rules.map(&:to_file) end
  def rules_to_s; rules.map(&:to_s) end

  def to_file
    ret = ":0 :\n"
    ret += rules_to_file.join("\n")+"\n"
    ret += actions_to_file
    ret
  end
  private

    def at_least_one_action_must_exist
      errors.add(:base, "At least one action must exist.") if actions.empty?
    end
    def at_least_one_rule_must_exist
      errors.add(:base, "At least one rule must exist.") if rules.empty?
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

