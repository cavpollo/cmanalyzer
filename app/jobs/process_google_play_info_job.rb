class ProcessGooglePlayInfoJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts 'STARTED'



    puts 'DONE'
  end
end
