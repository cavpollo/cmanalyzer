require 'csv'

class ProcessScreenPropertiesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts 'STARTED'

    last_data_load_date = DateTime.strptime('24/07/2014 12:00:00Z', '%d/%m/%Y %H:%M:%SZ')

    ldl = LastDataLoad.find_by(process_name: 'ProcessScreenPropertiesJob')
    unless ldl
      ldl = LastDataLoad.new
      ldl.process_name = 'ProcessScreenPropertiesJob'
      ldl.last_data_load_date = last_data_load_date
      ldl.save!
    end

    CSV.foreach('tmp/screenProperties.csv', :col_sep => ',', :headers => true, :return_headers => false) do |row|
      if row['test'] && (row['test'] == '' || row['test'] == 'false')
        keen_date = DateTime.strptime(row['keen.timestamp'], '%Y-%m-%dT%H:%M:%S.%LZ')
        if keen_date > ldl.last_data_load_date
          u_device = UniqueDevice.find_by(device_id: row['userID'])
          if u_device
            if u_device.last_play_date < keen_date
              u_device.last_play_date = keen_date
            end
            u_device.play_count = u_device.play_count + 1
            u_device.save
          else
            unique_device = UniqueDevice.new
            unique_device.device_id = row['userID']
            unique_device.device_density = row['density']
            unique_device.device_height = row['height']
            unique_device.device_width = row['width']
            unique_device.device_h_diff = row['worldHDiff']
            unique_device.play_count = 1
            unique_device.first_play_date = keen_date
            unique_device.last_play_date = keen_date
            unique_device.save
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
