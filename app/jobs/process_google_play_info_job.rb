require 'csv'

class ProcessGooglePlayInfoJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts 'STARTED'

    last_data_load_date = DateTime.strptime('24/07/2014 12:00:00Z', '%d/%m/%Y %H:%M:%SZ')

    ldl = LastDataLoad.find_by(process_name: 'ProcessGooglePlayInfoJob')
    unless ldl
      ldl = LastDataLoad.new
      ldl.process_name = 'ProcessGooglePlayInfoJob'
      ldl.last_data_load_date = last_data_load_date
      ldl.save!
    end

    CSV.foreach('tmp/googlePlayInfo.csv', :col_sep => ',', :headers => true, :return_headers => false) do |row|
      if row['test'] && (row['test'] == '' || row['test'] == 'false')
        keen_date = DateTime.strptime(row['keen.timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
        if keen_date > ldl.last_data_load_date
          u_device = UniqueDevice.find_by(device_id: row['userID'])
          if u_device
            u_user = u_device.unique_users.find_by(user_gplay_id: row['googlePlayUserID'])

            if u_user
              if u_user.last_play_date < keen_date
                u_user.last_play_date = keen_date
              end

              if u_user.user_gender == 'UNKNOWN' && (row['version'] == '2.3.1' || row['version'] == '2.4.1')
                u_user.user_gender = row['gender']
              end
            else
              u_user = u_device.unique_users.new
              u_user.user_gplay_id = row['googlePlayUserID']
              u_user.user_gender = row['version'] == '2.3.1' || row['version'] == '2.4.1' ? row['gender'] : 'UNKNOWN'
              u_user.user_language = row['language']
              u_user.first_play_date = keen_date
              u_user.last_play_date = keen_date
            end
            u_user.save!

            u_version = u_user.unique_versions.find_by(game_version: row['version'])
            if u_version
              u_version.play_count = u_version.play_count + 1
              u_version.save
            else
              u_user.unique_versions.create(game_version: row['version'], play_count: 1)
            end
          else
            puts "No Device found: #{row['userID']}"
          end
        end

        if last_data_load_date < keen_date
          last_data_load_date = keen_date
        end
      end
    end

    ldl.last_data_load_date = last_data_load_date
    ldl.save!

    puts 'DONE'
  end
end
