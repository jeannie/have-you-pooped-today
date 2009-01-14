class CreatePoopLogs < ActiveRecord::Migration
  def self.up
    create_table :poop_logs do |t|
      t.integer :facebook_user_id
      t.boolean :pooped

      t.timestamps
    end
  end

  def self.down
    drop_table :poop_logs
  end
end
