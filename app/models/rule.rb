# -*- coding: utf-8 -*-
class Rule < ActiveRecord::Base
  belongs_to :filter

  validates_presence_of :section, :substance, :part

  BEGINS_WITH = "begins_with"
  CC = "cc"
  CONTAINS = "contains"
  ENDS_WITH = "ends_with"
  FROM = "from"
  IS = "is"
  SUBJECT = "subject"
  TO = "to"
  TO_OR_CC = "to_or_cc"
  SPAM_FLAG = "spam_flag"

  SECTIONS = [SUBJECT, FROM, TO, CC, TO_OR_CC, SPAM_FLAG]
  PARTS = [CONTAINS, IS, BEGINS_WITH, ENDS_WITH]

  def beginning_to_file
    if substance_is_english?
      ret = "^"
      ret += Rule.section_to_file(section)
      ret += ":"
    else
      " SUB ?? " 
    end
  end
  def contents; [section, substance, part] end
  def end_to_file
    ret = ""
    ret += ".*" if part == CONTAINS or part == ENDS_WITH
    ret += " " if part == IS or part == BEGINS_WITH
    ret += substance.nil? ? "" : escape_dots(substance)
    ret += "$" if part == IS or part == ENDS_WITH
    ret
  end
  def humanized_part; part.gsub(/_/,' ') end 

  def substance=(s)
    self[:substance] = s.gsub(/\\\./,'.')
  end

  def to_file; ret = "*"+to_s end
  def to_s
    ret = beginning_to_file
    ret += end_to_file
    ret
  end

  def translated_section 
    I18n.t("rules.sections."+section.downcase.gsub(/\|/,'_or_'))
  end
  def translated_part_and_substance(end_change)
    s = I18n.t("rules.parts."+part) 
    if s.include?('次')
      s.gsub!(/次/,"「#{substance}」")
      if end_change
        s.gsub!(/む/,"み")
        s.gsub!(/する/,"し")
        s.gsub!(/る/,"り")
      end
    else
      s = %(#{s} "#{substance}")
    end
    s
  end

  class << self
    def map_section(s)
      return "" if s.nil?
      case s
      when "Subject"; SUBJECT
      when "To"; TO
      when "Cc"; CC
      when "From"; FROM
      when /X-Spam-Flag|X-Barracuda-Spam-Flag/; SPAM_FLAG
      when /To|Cc/i; TO_OR_CC
      else raise KeywordException, "Keyword '#{s}' not found."
      end
    end

    def parts; PARTS.map{|e| I18n.t("rules.parts.#{e}")}.zip(PARTS) end
    def sections; SECTIONS.map{|e| I18n.t("rules.sections.#{e}")}.zip(SECTIONS) end

    def section_to_file(s)
      case s
      when "subject"; "Subject"
      when "from"; "From"
      when "to"; "To"
      when "cc"; "Cc"
      when "to_or_cc"; "(To|Cc)"
      when "spam_flag"; "(X-Spam-Flag|X-Barracuda-Spam-Flag)"
      else raise KeywordException, "Keyword placeholder '#{s}' not found."
      end 
    end
  end

  private

    def escape_dots(s)
      s.gsub(/(\.[^*])/,"APA"+'\1').gsub(/APA/,'\\')
    end

    def substance_is_english?
    end
end


# == Schema Information
#
# Table name: rules
#
#  id         :integer(4)      not null, primary key
#  section    :string(255)
#  part       :string(255)
#  substance  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  filter_id  :integer(4)
#

