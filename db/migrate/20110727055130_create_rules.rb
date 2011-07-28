class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.string :section
      t.string :part
      t.string :substance
      t.integer :filter_id

      t.timestamps
    end
  end

  def self.down
    drop_table :rules
  end
end
