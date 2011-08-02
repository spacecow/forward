class AddUsernameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :username, :string
    add_column :users, :roles_mask, :integer
    remove_column :users, :email
  end

  def self.down
    remove_column :users, :username
    remove_column :users, :roles_mask
    add_column :users, :email, :string
  end
end
