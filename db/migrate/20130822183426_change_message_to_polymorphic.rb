class ChangeMessageToPolymorphic < ActiveRecord::Migration
  def up
    rename_column :messages, :post_id, :messageable_id
    add_column :messages, :messageable_type, :string

    add_index :messages, [:messageable_id, :messageable_type]
  end

  def down
  end
end
