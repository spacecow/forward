class Filter < ActiveRecord::Base
  include Procmail

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

  def actions_to_file
    if actions.count <= 1
      actions.first.to_file
    else
      ret = []
      actions.sort.each do |action|
        ret << action.multiple_action_to_file(actions.sort.last==action)
      end
      "{\n"+ret.join("\n\n")+"\n}"
    end
  end
  def actions_to_s; actions.map(&:to_s) end

  def rules_contents; rules.map(&:contents) end
  def rules_to_file; rules.map(&:to_file).join("\n") end
  def rules_to_s; rules.map(&:to_s) end

  def to_file
    ret = ":0"
    ret += "c" if one_action? && copy_message?
    ret += ":" if one_action? && move_message_to_folder?
    ret += "\n"+rules_to_file+"\n"
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

    def copy_message?; actions.first.copy_message? end
    def forward_message?; actions.first.forward_message? end
    def move_message_to_folder?; actions.first.move_message_to_folder? end
    def one_action?; actions.count == 1 end
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

