class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string  :subject
      t.text    :body
      t.string  :priority
      t.string  :message_type
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
