class ReadScreenPropertiesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    r = Keen.count('screenProperties', timeframe: {
        start: '2015-01-01T00:00:00Z',
        end: DateTime.now.utc.strftime('%Y-%m-%dT%I:%M:%SZ')
    })
    puts r
    # response = Net::HTTP.get_response("example.com","/?search=thing&format=json")
    # puts response.body
  end
end
