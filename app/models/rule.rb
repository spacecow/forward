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

  SECTIONS = [SUBJECT, FROM, TO, CC]
  PARTS = [CONTAINS, IS, BEGINS_WITH, ENDS_WITH]

  def contents
    [section, substance, part]
  end
  
  def self.parts; PARTS.map{|e| I18n.t("rules.parts.#{e}")}.zip(PARTS) end
  def self.sections; SECTIONS.map{|e| I18n.t("rules.sections.#{e}")}.zip(SECTIONS.map(&:capitalize)) end

  def to_file; ret = "*"+to_s end

  def to_s
    ret = "^"
    ret += section.nil? ? "" : section
    ret += ":"
    ret += ".*" if part == CONTAINS or part == ENDS_WITH
    ret += " " if part == IS or part == BEGINS_WITH
    ret += substance.nil? ? "" : substance
    ret += "$" if part == IS or part == ENDS_WITH
    ret
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
#  filter_id  :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

