class AddCreatedAtIndexToPirvateMessages < ActiveRecord::Migration
  def change
    add_index :private_messages, :created_at
  end
end
