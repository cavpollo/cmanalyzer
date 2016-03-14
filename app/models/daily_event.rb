class DailyEvent < ActiveRecord::Base
  validates :event_date, uniqueness: true
end
