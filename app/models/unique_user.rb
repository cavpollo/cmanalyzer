class UniqueUser < ActiveRecord::Base
  belongs_to :unique_device

  has_many :unique_versions

  #validates :user_gplay_id, presence: true, uniqueness: true
end
