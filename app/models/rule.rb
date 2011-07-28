class Rule < ActiveRecord::Base
  belongs_to :filter
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

