class SharePermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :share

  validates :user, :share, :permission, presence: true
end