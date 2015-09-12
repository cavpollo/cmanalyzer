class ReadScreenPropertiesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    timelapse = 12.hours
    puts 'STARTED'

    #search_date = DateTime.strptime('24/07/2014 12:00:00Z', '%d/%m/%Y %H:%M:%SZ')
    search_date = DateTime.strptime('2015-09-10 12:00:00Z', '%d/%m/%Y %H:%M:%SZ')
    while search_date < DateTime.now
      extraction_result = Keen.extraction('screenProperties',
        timeframe: {
          start: search_date.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
          end: (search_date + timelapse).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
        },
        filters: [{
          'property_name' => 'test',
          'operator' => 'eq',
          'property_value' => false
        }])

      extraction_result_2 = Keen.extraction('screenProperties',
        timeframe: {
          start: search_date.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
          end: (search_date + timelapse).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
        },
        filters: [{
          'property_name' => 'test',
          'operator' => 'exists',
          'property_value' => false
        }])

      extraction_result.concat(extraction_result_2)

      extraction_result.each do |row|
        u_device = UniqueDevice.find_by(device_id: row['userID'])
        if u_device
          daty = DateTime.strptime(row['keen']['timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
          if u_device.last_play_date < daty
            u_device.last_play_date = daty
          end
          u_device.save
        else
          unique_device = UniqueDevice.new
          unique_device.device_id = row['userID']
          unique_device.device_density = row['density']
          unique_device.device_height = row['height']
          unique_device.device_width = row['width']
          unique_device.device_h_diff = row['worldHDiff']
          unique_device.first_play_date = DateTime.strptime(row['keen']['timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
          unique_device.last_play_date = DateTime.strptime(row['keen']['timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
          unique_device.save
        end
      end

      search_date = search_date + timelapse
      puts "#{search_date} -> #{extraction_result.length}"
    end

    puts 'DONE'
  end
end
