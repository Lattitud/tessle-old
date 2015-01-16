class CreateTessleRelationships < ActiveRecord::Migration
  def change
    create_table :tessle_relationships do |t|
      t.integer :user_id
      t.integer :tag_id

      t.timestamps
    end

    add_index :tessle_relationships, :user_id
    add_index :tessle_relationships, :tag_id
    #This enforces uniqueness so that a user can't follow another tag more than once
    add_index :tessle_relationships, [:user_id, :tag_id], unique: true
  end
end
