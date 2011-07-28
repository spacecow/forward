class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.string :operation
      t.string :destination
      t.integer :filter_id

      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
