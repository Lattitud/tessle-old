class RemoveMessageLikes < ActiveRecord::Migration
  def change
    Vote.where("voteable_type = 'Message'").delete_all
  end
end
