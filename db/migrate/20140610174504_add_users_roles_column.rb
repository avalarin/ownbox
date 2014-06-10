class AddUsersRolesColumn < ActiveRecord::Migration
  def change
    add_column 'security.users', :roles, :string
  end
end
