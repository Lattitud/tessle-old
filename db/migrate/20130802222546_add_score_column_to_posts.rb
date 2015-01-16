class AddScoreColumnToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :score, :decimal
    add_index :posts, :score
  end
end
