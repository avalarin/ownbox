class User < ActiveRecord::Base
  self.table_name = 'security.users'
  before_save { 
    self.email = email.downcase 
    self.name = name.downcase
    self.home_directory ||= name 
  }
  
  validates :name, :email, :display_name, presence: true
  validates :name, :email, uniqueness: { case_sensitive: true }
  validates :name, length: { minimum: 5 }
  validates :email, email_format: { message: "doesn't look like an email address" }

  has_secure_password
  validates :password, :presence =>true, :confirmation => true, :length => { :within => 5..40 }, :on => :create
  validates :password, :confirmation => true, :length => { :within => 5..40 }, :on => :update, :unless => lambda{ |user| user.password.blank? }

  def full_home_directory
    base = File.expand_path(Settings['home_directories_path'])
    File.expand_path(home_directory, base)
  end

  def is_admin?
    has_role? :admin
  end

  def has_role? role
    roles.include? role.to_s
  end

  def roles= roles
    write_attribute(:roles, roles.join(';'))
  end

  def roles
    roles_str = read_attribute(:roles)
    roles_str ? roles_str.split(';') : []
  end

  def self.filters
    [:all, :locked, :not_approved]
  end

  def self.filter f
    case f
      when :all
        all
      when :locked
        where locked: true
      when :not_approved
        where approved: false
      else
        []
      end
  end

  def self.search text
    return all if text == nil || text.empty?
    search = "%#{text}%"
    all.where 'name like ? or display_name like ? or email like ?', search, search, search
  end

end