class LastDataLoad < ActiveRecord::Base
  validates :process_name, uniqueness: true
end
