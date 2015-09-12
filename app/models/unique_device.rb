class UniqueDevice < ActiveRecord::Base
  has_many :unique_users

  validates :device_id, presence: true, uniqueness: true
end
