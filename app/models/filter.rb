class Filter < ActiveRecord::Base
  include Procmail

  belongs_to :user

  has_many :rules, :dependent => :destroy
  accepts_nested_attributes_for :rules, :allow_destroy => true

  has_many :actions, :dependent => :destroy
  accepts_nested_attributes_for :actions, :allow_destroy => true

  validate :at_least_one_action_must_exist
  validate :at_least_one_rule_must_exist

  MATCH_ALL = "match_all"
  MATCH_ANY = "match_any"
  GLUES = [MATCH_ALL, MATCH_ANY]

  def contents; [rules.map(&:contents), actions.map(&:contents)] end

  def actions_contents; actions.map(&:contents) end
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
  def action 
    raise Exception, "Referring to 'the action' but there are many." if first_action != last_action
    first_action
  end
  def action_destination; action.destination end
  def actions_to_s; actions.map(&:to_s) end

  def first_action; actions.first end
  def first_rule; rules.first end
  def first_rules_contents; first_rule.contents end

  def section?(section)
    rules.map(&section).include?(true)
  end
  def japanese_cc?; section?(:japanese_cc?) end
  def japanese_sender?; section?(:japanese_sender?) end
  def japanese_subject?; section?(:japanese_subject?) end
  def japanese_recipient?; section?(:japanese_recipient?) end
  def japanese_to_or_cc?; section?(:japanese_to_or_cc?) end

  def last_action; actions.last end
  def last_rule; rules.last end 
  def last_rules_contents; last_rule.contents end
  def rule
    raise Exception, "More than one rule." if first_rule != last_rule
    first_rule
  end
  def rule_contents; rule.contents end
  def rule_section; rule.section end
  def rules_contents; rules.map(&:contents) end
  def rules_to_file
    if glue == "and"
      rules.map(&:to_file).join("\n") 
    elsif rules_section_is_unique?
      if rules_include_japanese? 
        ret = "*#{first_rule.beginning_to_file_in_japanese}"
        ret + "(#{rules.map(&:end_to_file_in_japanese).join('|')})"
      else
        ret = "*#{first_rule.beginning_to_file_in_english}"
        ret + "(#{rules.map(&:end_to_file_in_english).join('|')})"
      end
    elsif rules_include_japanese? #and are more than one
      rules.map{|e| "* ! #{e.beginning_to_file.lstrip}#{e.end_to_file}"}.join("\n")
    else
      "*#{rules.map(&:to_s).join('|')}"
    end
  end
  def rules_to_s; rules.map(&:to_s) end

  def to_file
    ret = ":0"
    if one_action? and copy_message?
      ret += "c" unless de_morgan?
    end
    if one_action? and move_message_to_folder?
      ret += ":" unless de_morgan?
    end
    ret += "\n"+rules_to_file+"\n"
    if de_morgan? and glue == "or"
      ret += "{ }\n:0E" 
      ret += "c" if one_action? and copy_message?
      ret += ":" if one_action? and move_message_to_folder?
      ret += "\n"
    end
    ret += actions_to_file unless actions.empty?
    ret
  end

  class << self
    def glues; GLUES.map{|e| I18n.t("filters.glues.#{e}")}.zip(["and","or"]) end
  end

  private

    def at_least_one_action_must_exist
      errors.add(:base, "At least one action must exist.") if actions.empty? unless Rails.env == "test"
    end
    def at_least_one_rule_must_exist
      errors.add(:base, "At least one rule must exist.") if rules.empty? unless Rails.env == "test"
    end

    def copy_message?; actions.first.copy_message? end
    def de_morgan?
      !rules_section_is_unique? and rules_include_japanese?
    end
    def forward_message?; actions.first.forward_message? end
    def move_message_to_folder?; first_action.move_message_to_folder? end
    def one_action?; actions.count == 1 end
    def rules_section_is_unique?; rules.map(&:section).uniq.size == 1 end
    def rules_include_japanese?
      rules.map(&:substance_is_english?).include?(nil)
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
#  glue       :string(255)     default("and")
#

