class UniqueVersion < ActiveRecord::Base
  belongs_to :unique_user

  #validates :game_version, presence: true, uniqueness: true
end
