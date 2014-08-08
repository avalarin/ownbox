class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.string :path
      t.string :full_path
      t.integer :user_id
      t.string :type
      t.string :class_name
    end

    add_index :items, [:path, :user_id]
  end
end
