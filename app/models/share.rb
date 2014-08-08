class Share < ActiveRecord::Base
  validates :name, :item, presence: true
  validates :name, length: { minimum: 3 }

  belongs_to :item, class_name: 'DataItem', foreign_key: 'item_id'

  def self.find_by_user_and_name user, name
    Share.joins(:item).where(items: { user_id: user.id }, name: name).first
  end

  def self.get_by_user user
    Share.joins(:item).where(items: { user_id: user.id })
  end

end