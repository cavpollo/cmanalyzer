class ReadUsersPerDeviceJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    timelapse = 12.hours
    puts 'STARTED'

    search_date = DateTime.strptime('24/07/2014 12:00:00Z', '%d/%m/%Y %H:%M:%SZ')
    while search_date < DateTime.now
      extraction_result = Keen.extraction('googlePlayInfo',
        timeframe: {
          start: search_date.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
          end: (search_date + timelapse).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
        },
        filters: [{
          'property_name' => 'test',
          'operator' => 'eq',
          'property_value' => false
        }])

      extraction_result_2 = Keen.extraction('googlePlayInfo',
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
          u_user = u_device.unique_users.find_by(user_gplay_id: row['googlePlayUserID'])

          if u_user
            daty = DateTime.strptime(row['keen']['timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
            if u_user.last_play_date < daty
              u_user.last_play_date = daty
            end
            if u_user.user_gender == 'UNKNOWN' && (row['version'] == '2.3.1' || row['version'] == '2.4.1')
              u_user.user_gender = row['gender']
            end
          else
            u_user = u_device.unique_users.new
            u_user.user_gplay_id = row['googlePlayUserID']
            u_user.user_gender = row['version'] == '2.3.1' || row['version'] == '2.4.1' ? row['gender'] : 'UNKNOWN'
            u_user.user_language = row['language']
            u_user.first_play_date = DateTime.strptime(row['keen']['timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
            u_user.last_play_date = DateTime.strptime(row['keen']['timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
          end
          u_user.save!

          u_user.unique_versions.create(game_version: row['version']) unless u_user.unique_versions.find_by(game_version: row['version'])
        else
          puts "No Device found: #{row['userID']}"
        end
      end

      search_date = search_date + timelapse
      #puts "#{search_date} -> #{extraction_result.length}"
    end

    puts 'DONE'
  end
end
