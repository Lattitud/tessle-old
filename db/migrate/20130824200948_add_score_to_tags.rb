class AddScoreToTags < ActiveRecord::Migration
  def change
    add_column :tags, :score, :decimal
    add_index :tags, :score
  end
end
