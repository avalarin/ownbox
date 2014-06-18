class CreateInvites < ActiveRecord::Migration
  def change
    create_table :'security.invites' do |t|
      t.string :code
      t.integer :user_id
      t.boolean :activated
    end
  end
end
