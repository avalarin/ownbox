class CreateSharePermissions < ActiveRecord::Migration
  def change
    create_table :share_permissions do |t|
      t.integer :user_id
      t.integer :share_id
      t.string :permission
    end
  end
end
