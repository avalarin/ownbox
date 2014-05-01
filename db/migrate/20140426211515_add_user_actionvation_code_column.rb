class AddUserActionvationCodeColumn < ActiveRecord::Migration
  def change
    add_column 'security.users', :activation_code, :string
  end
end
