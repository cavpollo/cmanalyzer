class MailDataJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts 'STARTED'

    dateA = DateTime.strptime('24/07/2014 12:00:00Z', '%d/%m/%Y %H:%M:%SZ').strftime('%Y-%m-%dT%H:%M:%SZ')
    dateB = DateTime.now.strftime('%Y-%m-%dT%H:%M:%SZ')

    event_names = ['androidDeviceInfo', 'artSeen', 'coinState', 'enterScreen', 'gameData', 'googlePlayInfo', 'openLink', 'screenProperties', 'sendError', 'setSquareStyle']

    event_names.each do |event|
      extraction_result = Keen.extraction(event,
                                          timeframe: {
                                              start: dateA,
                                              end: dateB
                                          },
                                          email: 'cavpollo@gmail.com')
      puts event
      puts extraction_result.inspect
    end

    puts 'DONE'
  end
end
