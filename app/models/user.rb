class User < ActiveRecord::Base
  self.table_name = 'security.users'
  before_save { self.email = email.downcase }
  
  validates :name, :email, :home_directory, :display_name, presence: true
  validates :name, :email, uniqueness: { case_sensitive: false }
  validates :name, length: { minimum: 5 }
  validates :email, email_format: { message: "doesn't look like an email address" }

  has_secure_password
  validates :password, length: { minimum: 5 }

  def full_home_directory
    base = File.expand_path(Settings['home_directories_path'])
    File.expand_path(home_directory, base)
  end

end