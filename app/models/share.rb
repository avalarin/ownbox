class Share < ActiveRecord::Base
  validates :name, :path, presence: true
  validates :name, length: { minimum: 5 }

  belongs_to :user

  def self.find_by_user_and_name user, name
    Share.where("user_id = ? and name = ?", user.id, name).first
  end

  def self.get_by_user user
    Share.where("user_id = ?", user.id)
  end

end