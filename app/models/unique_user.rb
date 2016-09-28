class UniqueUser < ActiveRecord::Base
  belongs_to :unique_device

  has_many :screen_user_days
  has_many :game_events

  #validates :user_gplay_id, presence: true, uniqueness: true
end
