class UniqueDevice < ActiveRecord::Base
  has_many :unique_users
  has_many :unique_versions
  has_many :user_screen_events

  validates :device_id, presence: true, uniqueness: true
end
