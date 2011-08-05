class Rule < ActiveRecord::Base
  belongs_to :filter

  PARTS = ["contains", "doesn't contain", "is", "isn't", "begins with", "ends with"]

  def contents
    [section, substance, part]
  end

  def to_file; ret = "*"+to_s end

  def to_s
    ret = "^"
    ret += section
    ret += ":"
    ret += ".*" if part == "contains" or part == "ends with"
    ret += " " if part == "is" or part == "begins with"
    ret += substance
    ret += "$" if part == "is" or part == "ends with"
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

