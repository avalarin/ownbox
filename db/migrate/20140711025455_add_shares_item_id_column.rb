class AddSharesItemIdColumn < ActiveRecord::Migration
  def change
    add_column :shares, :item_id, :integer
    remove_column :shares, :path, :string
    remove_column :shares, :user_id, :integer
  end
end
