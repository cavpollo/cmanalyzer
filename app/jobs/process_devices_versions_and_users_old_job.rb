require 'csv'

class ProcessDevicesVersionsAndUsersOldJob < ActiveJob::Base
  queue_as :default

  DATE_FORMAT = '%m/%d/%Y %H:%M'
  LAST_DATE_STRING = '06/01/2014 00:00'
  PROCESS_1 = 'ProcessDevicesVersionsAndUsersOld'

  def get_ldl(process_name)
    ldl = LastDataLoad.find_by(process_name: process_name)
    if ldl.nil?
      ldl = LastDataLoad.new
      ldl.process_name = process_name
      ldl.last_keen_id = '0'
      ldl.last_keen_date = DateTime.strptime(LAST_DATE_STRING, DATE_FORMAT)
      ldl.save!
    end
    ldl
  end

  def not_test_conditions(test, version)
    ((!test.nil? && (test.is_a?(FalseClass) || (test.is_a?(String) && test == 'false'))) || test.nil?) && %w(2.4.1 2.4.0 2.3.5 2.3.1 2.3.0 2.1.1 2.1.0).include?(version)
  end
  
  def perform(*args)
    puts 'STARTED'

    ldl = get_ldl(PROCESS_1)
    puts "\nSTART PROCESS: #{PROCESS_1}"

    date_set = false
    CSV.foreach('tmp/ColorMandess-2014_06_01-2016_02_22-Flurry.csv', col_sep: ',', headers: true, return_headers: false) do |row|
      if row['Event'] == 'LoadingScreen' && %w(1.0.14 1.1.0).include?(row['Version'])
        flurry_date = DateTime.strptime(row['Timestamp'], DATE_FORMAT)

        unless date_set
          ldl.last_keen_date = flurry_date
          ldl.save!
          date_set = true
        end

        u_device = UniqueDevice.find_by(device_id: row['User ID'])
        if u_device
          if u_device.last_play_date < flurry_date
            u_device.last_play_date = flurry_date
          end
          if u_device.device_device == ''
            u_device.device_device = row['Device']
            puts row['Device']
          end
          u_device.play_count = u_device.play_count + 1
          u_device.save!
        else
          params = row['Params'].split(';').reject{|param| /(pixelsHeight|pixelsWidth|extraH)/.match(param).nil?}.map!{|param| [/(pixelsHeight|pixelsWidth|extraH)/.match(param)[0], /(pixelsHeight|pixelsWidth|extraH)\s*:\s*(\d+\.?\d*)/.match(param)[2]]}.to_h
          device_info = check_device(row['Device'])

          u_device = UniqueDevice.new
          u_device.device_id = row['User ID']
          u_device.device_model = ''
          u_device.device_device = row['Device']
          u_device.device_brand = device_info[:brand]
          u_device.device_name = device_info[:name]
          u_device.device_model = device_info[:model]
          u_device.device_density = 0
          u_device.device_height = params['pixelsHeight'].to_i
          u_device.device_width = params['pixelsWidth'].to_i
          u_device.device_h_diff = params['extraH'].to_f
          u_device.play_count = 1
          u_device.first_play_date = flurry_date
          u_device.last_play_date = flurry_date
          u_device.save!
        end

        u_version = u_device.unique_versions.find_by(game_version: row['Version'])
        if u_version
          u_version.play_count = u_version.play_count + 1
          if u_version.last_play_date < flurry_date
            u_version.last_play_date = flurry_date
          end
          u_version.save
        else
          u_device.unique_versions.create(game_version: row['Version'], play_count: 1, first_play_date: flurry_date, last_play_date: flurry_date)
        end
      end
    end

    puts "END PROCESS: #{PROCESS_1}"

    puts 'DONE'
  end
  
  def check_device(device)
    big_list = {
        'Google Nexus 5' => {brand: 'LGE', name: 'Nexus 5', model: 'Nexus 5'},
        'Lanix  ILIUM S410' => {brand: 'Lanix', name: 'Ilium S410', model: 'ILIUM S410'},
        'Samsung Galaxy Young (GT-S6310)' => {brand: 'Samsung', name: 'Galaxy Young', model: 'GT-S6310'},
        'LG Optimus L5 E610' => {brand: 'LGE', name: 'Optimus L5', model: 'LG-E610'},
        'Samsung Galaxy WinDuos GT-I8552B' => {brand: 'Samsung', name: 'Galaxy Win', model: 'GT-I8552B'},
        'Huawei  P6-U06' => {brand: 'Huawei', name: 'HUAWEI P6', model: 'HUAWEI P6-U06'}}

    big_list[device]
  end
end
