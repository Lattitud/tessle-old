class ChangeStringFormatInMessages < ActiveRecord::Migration
  def up
    change_column :messages, :content, :text
    add_index :messages, :post_id
  end

  def down
  end
end
