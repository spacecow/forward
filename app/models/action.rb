class Action < ActiveRecord::Base
  belongs_to :filter

  def contents
    [operation, destination]
  end

  def to_file; to_s end
  def to_s; destination end
end

# == Schema Information
#
# Table name: actions
#
#  id          :integer(4)      not null, primary key
#  operation   :string(255)
#  destination :string(255)
#  filter_id   :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

