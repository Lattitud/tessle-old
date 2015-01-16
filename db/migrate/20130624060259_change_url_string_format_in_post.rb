class ChangeUrlStringFormatInPost < ActiveRecord::Migration
  def up
    change_column :posts, :url, :text
  end

  def down
  end
end
