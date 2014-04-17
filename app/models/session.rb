class Session < ActiveRecord::Base
  self.table_name = 'security.sessions'

  belongs_to :user
end