class AddGlueToFilter < ActiveRecord::Migration
  def self.up
    add_column :filters, :glue, :string, :default => "and"
  end

  def self.down
    remove_column :filters, :glue
  end
end
