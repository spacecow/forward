class Message < ActiveRecord::Base
  belongs_to :user

  attr_accessible :subject, :body, :priority, :message_type
  validates_presence_of :subject, :body, :priority, :message_type

  PRIORITIES = %w(low normal high urgent)
  TYPES = %w(bug enhancement feature comment)

  def self.priorities; PRIORITIES.map{|e| I18n.t("messages.priorities.#{e}")}.zip(PRIORITIES) end
  def self.types; TYPES.map{|e| I18n.t("messages.types.#{e}")}.zip(TYPES) end

#bug, enhancement feature comment
end

# == Schema Information
#
# Table name: messages
#
#  id           :integer(4)      not null, primary key
#  subject      :string(255)
#  body         :text
#  priority     :string(255)
#  message_type :string(255)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

