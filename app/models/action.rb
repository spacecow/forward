class Action < ActiveRecord::Base
  include Comparable

  belongs_to :filter

  def <=>(action)
    if self.copy_message?
      -1
    elsif action.copy_message?
      1
    else
      -1
    end 
  end

  def copy_message?; operation.include?("Copy") end
  def forward_message?; operation.include?("Forward") end
  def move_message_to_folder?; !forward_message? end
  def multiple_action_to_file(last)
    ret = "\t:0"
    ret += "c" if copy_message? or !last
    ret += ":" if move_message_to_folder?
    ret += "\n"
    ret += "\t"
    ret += "!" + to_s if forward_message?
    ret += "." + to_s + "/" if move_message_to_folder?
    ret
  end

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

