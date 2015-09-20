class UniqueUser < ActiveRecord::Base
  belongs_to :unique_device

  #validates :user_gplay_id, presence: true, uniqueness: true
end
