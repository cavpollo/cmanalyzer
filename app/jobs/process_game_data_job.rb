class ProcessGameDataJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts 'STARTED'

    #Use the oldest from both ScreenProperties and GPlayInfo load dates as the max load date

    puts 'DONE'
  end
end
