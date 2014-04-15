class CreateUsers < ActiveRecord::Migration
  def change
    create_table 'security.users' do |t|
      t.string :name
      t.string :email
      t.boolean :approved, default: false
      t.boolean :locked, default: false
      t.datetime :last_login_at
      t.string :password_digest
      t.string :display_name
      t.string :home_directory
      t.timestamps
    end
  end
end