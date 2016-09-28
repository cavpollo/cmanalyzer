class GameEvent < ActiveRecord::Base
  belongs_to :unique_user
  belongs_to :unique_device

end
