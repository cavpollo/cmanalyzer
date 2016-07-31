require 'csv'

class ProcessScreenActivityJob < ActiveJob::Base
  queue_as :default

  DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%LZ'
  LAST_DATE_STRING = '2014-06-04T06:00:00.000Z'
  DATE_STEP = 2.months
  PROCESS_1 = 'ProcessScreenActivityJob-enterScreen'
  PROCESS_2 = 'ProcessScreenActivityJob-screenDays'
  PROCESS_3 = 'ProcessScreenActivityJob-screenUserDays'

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

    now_date = Time.zone.now

    #Extractions are rate limited at 1,000/minute, but are considered separately from query rate limiting.
    #The maximum number of events that can be returned in a synchronous JSON response is 100,000. Requests exceeding this limit will error.

    ldl = get_ldl(PROCESS_1)
    puts "\nSTART PROCESS: #{PROCESS_1}"
    start_date_s = ldl.last_keen_date - DATE_STEP
    # new_t = 0
    # update_t = 0
    begin
      start_date_s = start_date_s + DATE_STEP
      end_date_s = start_date_s + DATE_STEP
      enterScreen = Keen.extraction('enterScreen',
                                         timeframe: {start: start_date_s.strftime(DATE_FORMAT), end: end_date_s.strftime(DATE_FORMAT)}
      )#filters: [{operator: 'gt', property_name: 'keen.id', property_value: ldl.last_keen_id}])

      puts "FOUND #{enterScreen.size} - #{ldl.last_keen_date} - #{ldl.last_keen_id}"
      if enterScreen.size > 0
        enterScreen.sort_by! { |hsh| hsh['keen']['timestamp'] }
        # puts "ID RANGE: [#{enterScreen.first['keen']['id']} - #{enterScreen.last['keen']['id']}]"
        puts "DATE RANGE: [#{enterScreen.first['keen']['timestamp']} - #{enterScreen.last['keen']['timestamp']}]"
      end

      # new_c = 0
      # update_c = 0
      enterScreen.each do |row|
        if not_test_conditions(row['test'], row['version'])
          keen_date = DateTime.strptime(row['keen']['timestamp'], DATE_FORMAT)

          u_device = UniqueDevice.find_by(device_id: row['userID'])
          if u_device
            # update_c = update_c + 1
            if u_device.last_play_date < keen_date
              u_device.last_play_date = keen_date
            end
            u_device.save!
          else
            # new_c = new_c + 1
            u_device = UniqueDevice.new
            u_device.device_id = row['userID']
            u_device.device_model = ''
            u_device.device_device = ''
            u_device.device_density = 0
            u_device.device_height = 0
            u_device.device_width = 0
            u_device.device_h_diff = 0
            u_device.play_count = 0
            u_device.first_play_date = keen_date
            u_device.last_play_date = keen_date
            u_device.valid_device = false
            u_device.save!
          end

          u_s_e = UserScreenEvent.find_by(unique_device_id: u_device.id, screen_name: row['screenName'])
          if u_s_e
            # update_c = update_c + 1
            if u_s_e.last_date < keen_date
              u_s_e.last_date = keen_date
            end
            u_s_e.access_count = u_s_e.access_count + 1
            u_s_e.save!
          else
            # new_c = new_c + 1
            u_s_e = UserScreenEvent.new
            u_s_e.unique_device_id = u_device.id
            u_s_e.screen_name = row['screenName']
            u_s_e.access_count = 1
            u_s_e.first_date = keen_date
            u_s_e.last_date = keen_date
            u_s_e.save!
          end
        else
          puts "REJECTED: T:[#{row['test'].inspect}] V:[#{row['version'].inspect}], #{row['test'].nil?}, #{row['test'].is_a?(FalseClass)}, #{row['test'].is_a?(String)}"
        end
      end

      # puts "COUNT - NEW:#{new_c} - UPDATE:#{update_c}"
      #new_t = new_t + new_c
      #update_t = update_t + update_c

      if enterScreen.size > 0
        ldl.last_keen_id = enterScreen.last['keen']['id']
        ldl.last_keen_date = DateTime.strptime(enterScreen.last['keen']['timestamp'], DATE_FORMAT)
        ldl.save!
      end
    end while end_date_s < now_date
    # puts "COUNT - NEW_T:#{new_t} - UPDATE_T:#{update_t}"
    puts "END PROCESS: #{PROCESS_1}"

    ldl = get_ldl(PROCESS_2)
    puts "\nSTART PROCESS: #{PROCESS_2}"
    start_date_s = ldl.last_keen_date - DATE_STEP
    # new_t = 0
    # update_t = 0
    begin
      start_date_s = start_date_s + DATE_STEP
      end_date_s = start_date_s + DATE_STEP
      enterScreen = Keen.extraction('enterScreen',
                                    timeframe: {start: start_date_s.strftime(DATE_FORMAT), end: end_date_s.strftime(DATE_FORMAT)}
      )#filters: [{operator: 'gt', property_name: 'keen.id', property_value: ldl.last_keen_id}])

      puts "FOUND #{enterScreen.size} - #{ldl.last_keen_date} - #{ldl.last_keen_id}"
      if enterScreen.size > 0
        enterScreen.sort_by! { |hsh| hsh['keen']['timestamp'] }
        # puts "ID RANGE: [#{enterScreen.first['keen']['id']} - #{enterScreen.last['keen']['id']}]"
        puts "DATE RANGE: [#{enterScreen.first['keen']['timestamp']} - #{enterScreen.last['keen']['timestamp']}]"
      end

      # new_c = 0
      # update_c = 0
      enterScreen.each do |row|
        if not_test_conditions(row['test'], row['version'])
          keen_date = DateTime.strptime(row['keen']['timestamp'], DATE_FORMAT)

          u_device = UniqueDevice.find_by(device_id: row['userID'])
          next if u_device.nil?

          days = ((keen_date.to_f - u_device.first_play_date.to_datetime.to_f) / (3600 * 24)).to_i + 1
          if days <= 0
            puts "1: #{days} = #{u_device.first_play_date.inspect} - #{keen_date.inspect}"
            puts "1: #{u_device.first_play_date.to_datetime} vs #{keen_date}"
          end

          u_s_d_1 = UserScreenDay.find_by(data_type: 1, day: days, screen_name: row['screenName'])
          if u_s_d_1
            # update_c = update_c + 1
            u_s_d_1.access_count = u_s_d_1.access_count + 1
            u_s_d_1.save!
          else
            # new_c = new_c + 1
            u_s_d_1 = UserScreenDay.new
            u_s_d_1.data_type = 1
            u_s_d_1.day = days
            u_s_d_1.screen_name = row['screenName']
            u_s_d_1.access_count = 1
            u_s_d_1.save!
          end

          days = ((u_device.last_play_date.to_datetime.to_f - u_device.first_play_date.to_datetime.to_f) / (3600 * 24)).to_i + 1
          if days <= 0
            puts "2: #{days} = #{u_device.first_play_date.inspect} - #{u_device.last_play_date.inspect}"
            puts "2: #{u_device.first_play_date.to_datetime} vs #{u_device.last_play_date.to_datetime}"
          end

          u_s_d_2 = UserScreenDay.find_by(data_type: 2, day: days, screen_name: row['screenName'])
          if u_s_d_2
            # update_c = update_c + 1
            u_s_d_2.access_count = u_s_d_2.access_count + 1
            u_s_d_2.save!
          else
            # new_c = new_c + 1
            u_s_d_2 = UserScreenDay.new
            u_s_d_2.data_type = 2
            u_s_d_2.day = days
            u_s_d_2.screen_name = row['screenName']
            u_s_d_2.access_count = 1
            u_s_d_2.save!
          end
        else
          # puts "REJECTED: T:[#{row['test'].inspect}] V:[#{row['version'].inspect}], #{row['test'].nil?}, #{row['test'].is_a?(FalseClass)}, #{row['test'].is_a?(String)}"
        end
      end

      # puts "COUNT - NEW:#{new_c} - UPDATE:#{update_c}"
      #new_t = new_t + new_c
      #update_t = update_t + update_c

      if enterScreen.size > 0
        ldl.last_keen_id = enterScreen.last['keen']['id']
        ldl.last_keen_date = DateTime.strptime(enterScreen.last['keen']['timestamp'], DATE_FORMAT)
        ldl.save!
      end
    end while end_date_s < now_date
    # puts "COUNT - NEW_T:#{new_t} - UPDATE_T:#{update_t}"
    puts "END PROCESS: #{PROCESS_2}"

    ldl = get_ldl(PROCESS_3)
    puts "\nSTART PROCESS: #{PROCESS_3}"
    start_date_s = ldl.last_keen_date - DATE_STEP
    # new_t = 0
    # update_t = 0
    begin
      start_date_s = start_date_s + DATE_STEP
      end_date_s = start_date_s + DATE_STEP
      enterScreen = Keen.extraction('enterScreen',
                                    timeframe: {start: start_date_s.strftime(DATE_FORMAT), end: end_date_s.strftime(DATE_FORMAT)}
      )#filters: [{operator: 'gt', property_name: 'keen.id', property_value: ldl.last_keen_id}])

      puts "FOUND #{enterScreen.size} - #{ldl.last_keen_date} - #{ldl.last_keen_id}"
      if enterScreen.size > 0
        enterScreen.sort_by! { |hsh| hsh['keen']['timestamp'] }
        # puts "ID RANGE: [#{enterScreen.first['keen']['id']} - #{enterScreen.last['keen']['id']}]"
        puts "DATE RANGE: [#{enterScreen.first['keen']['timestamp']} - #{enterScreen.last['keen']['timestamp']}]"
      end

      # new_c = 0
      # update_c = 0
      enterScreen.each do |row|
        if not_test_conditions(row['test'], row['version'])
          keen_date = DateTime.strptime(row['keen']['timestamp'], DATE_FORMAT)

          u_device = UniqueDevice.find_by(device_id: row['userID'])
          next if u_device.nil?

          days = ((keen_date.to_f - u_device.first_play_date.to_datetime.to_f) / (3600 * 24)).to_i + 1
          if days <= 0
            puts "#{days} = #{u_device.first_play_date.inspect} - #{u_device.last_play_date.inspect}"
            puts "#{u_device.first_play_date.to_datetime} vs #{u_device.last_play_date.to_datetime}"
          end

          s_u_d_2 = ScreenUserDay.find_by(unique_device_id: u_device.id, day: days, screen_name: row['screenName'])
          if s_u_d_2
            # update_c = update_c + 1
            s_u_d_2.access_count = s_u_d_2.access_count + 1
            s_u_d_2.save!
          else
            u_user = UniqueUser.find_by(user_gplay_id: row['googlePlayUserID'])

            # new_c = new_c + 1
            s_u_d_2 = ScreenUserDay.new
            s_u_d_2.unique_device_id = u_device.id
            s_u_d_2.unique_user_id = u_user.id if u_user
            s_u_d_2.day = days
            s_u_d_2.screen_name = row['screenName']
            s_u_d_2.access_count = 1
            s_u_d_2.version = row['version']
            s_u_d_2.save!
          end
        else
          # puts "REJECTED: T:[#{row['test'].inspect}] V:[#{row['version'].inspect}], #{row['test'].nil?}, #{row['test'].is_a?(FalseClass)}, #{row['test'].is_a?(String)}"
        end
      end

      # puts "COUNT - NEW:#{new_c} - UPDATE:#{update_c}"
      #new_t = new_t + new_c
      #update_t = update_t + update_c

      if enterScreen.size > 0
        ldl.last_keen_id = enterScreen.last['keen']['id']
        ldl.last_keen_date = DateTime.strptime(enterScreen.last['keen']['timestamp'], DATE_FORMAT)
        ldl.save!
      end
    end while end_date_s < now_date
    # puts "COUNT - NEW_T:#{new_t} - UPDATE_T:#{update_t}"
    puts "END PROCESS: #{PROCESS_3}"
  end
end