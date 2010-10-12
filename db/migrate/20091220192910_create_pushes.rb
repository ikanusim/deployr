class CreatePushes < ActiveRecord::Migration
  def self.up
    create_table :pushes do |t|
      t.text :payload
      t.boolean :processing, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :pushes
  end
end
