class CreatePppIndices < ActiveRecord::Migration
  def self.up
    create_table :ppp_indices do |t|
      t.integer :facebook_user_id
      t.integer :poop_count
      t.float :ppp_index

      t.timestamps
    end
  end

  def self.down
    drop_table :ppp_indices
  end
end
