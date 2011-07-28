class CreateFilters < ActiveRecord::Migration
  def self.up
    create_table :filters do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :filters
  end
end
