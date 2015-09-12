class MailGooglePlayInfoJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts 'STARTED'

    dateA = DateTime.strptime('24/07/2014 12:00:00Z', '%d/%m/%Y %H:%M:%SZ').strftime('%Y-%m-%dT%H:%M:%SZ')
    dateB = DateTime.now.strftime('%Y-%m-%dT%H:%M:%SZ')

    extraction_result = Keen.extraction('googlePlayInfo',
                                        timeframe: {
                                            start: dateA,
                                            end: dateB
                                        },
                                        email: 'cavpollo@gmail.com')

    puts extraction_result.inspect

    puts 'DONE'
  end
end
