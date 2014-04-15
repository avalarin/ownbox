class CreateSecuritySchema < ActiveRecord::Migration
  def up
    execute "CREATE SCHEMA security;"
  end
  def down
    execute "DROP SCHEMA security;"
  end
end
