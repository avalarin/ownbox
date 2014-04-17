class CreateSessions < ActiveRecord::Migration
  def change
    create_table 'security.sessions', id: false do |t|
      t.uuid :id, primary_key: true
      t.integer :user_id
      t.boolean :persistent, default: false
      t.boolean :closed, default: false
      t.datetime :closed_at
      t.datetime :expires_at
      t.timestamps
    end
  end
end
