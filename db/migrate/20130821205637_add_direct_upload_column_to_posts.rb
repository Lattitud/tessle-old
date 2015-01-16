class AddDirectUploadColumnToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :direct_upload_url, :text
  end
end
