class UniqueDevice < ActiveRecord::Base
  has_many :unique_users
  has_many :unique_versions

  validates :device_id, presence: true, uniqueness: true
end
