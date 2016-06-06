class ScreenUserDay < ActiveRecord::Base
  belongs_to :unique_device
  belongs_to :unique_user

end
