class Action < ActiveRecord::Base
  include Comparable

  belongs_to :filter

  validates_presence_of :destination, :operation

  COPY_MESSAGE_TO = "copy_message_to"
  FORWARD_COPY_TO = "forward_copy_to"
  FORWARD_MESSAGE_TO = "forward_message_to"
  MOVE_MESSAGE_TO = "move_message_to"

  OPERATIONS = [MOVE_MESSAGE_TO, COPY_MESSAGE_TO, FORWARD_MESSAGE_TO, FORWARD_COPY_TO]

  def <=>(action)
    if self.copy_message?
      -1
    elsif action.copy_message?
      1
    else
      -1
    end 
  end

  def contents; [operation, destination] end
  def copy_message?; operation.include?("copy") end
  def destination_to_file
    ret = ""
    ret += "!" + to_s if forward_message?
    ret += "." + to_s + "/" if move_message_to_folder?
    ret
  end
  def forward_message?; operation.include?("forward") end
  def move_message_to_folder?; !forward_message? end
  def multiple_action_to_file(last)
    ret = "\t:0"
    ret += "c" if copy_message? or !last
    ret += ":" if move_message_to_folder?
    ret += "\n"
    ret += "\t"
    ret += destination_to_file
    ret
  end
  def humanized_operation; operation.split('_').map(&:capitalize).join(' ').gsub(/To/,'to') end
  def self.operations; OPERATIONS.map{|e| I18n.t("actions.operations.#{e}")}.zip(OPERATIONS) end
  def to_file; destination_to_file end
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

