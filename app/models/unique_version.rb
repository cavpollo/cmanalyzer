class UniqueVersion < ActiveRecord::Base
  belongs_to :unique_device

  #validates :game_version, presence: true, uniqueness: true
end
