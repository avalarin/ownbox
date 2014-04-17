class CreatePreview < ActiveRecord::Migration
  def change
    create_table :previews do |t|
      t.string :path
      t.integer :size
      t.binary :data
    end
  end
end
