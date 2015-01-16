class CreatePrivateMessagesTable < ActiveRecord::Migration
  def up
    create_table :private_messages do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.text :content

      t.timestamps
    end

    add_index :private_messages, :sender_id
    add_index :private_messages, :recipient_id
  end

  def down
    drop_table :private_messages
  end
end
