class ProcessGameDataJob < ActiveJob::Base
  queue_as :default

  DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%LZ'
  LAST_DATE_STRING = '2014-06-04T06:00:00.000Z'
  DATE_STEP = 2.weeks
  PROCESS_1 = 'ProcessGameDataJob-gameData'

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
      gameData = Keen.extraction('gameData',
                                    timeframe: {start: start_date_s.strftime(DATE_FORMAT), end: end_date_s.strftime(DATE_FORMAT)}
      )#filters: [{operator: 'gt', property_name: 'keen.id', property_value: ldl.last_keen_id}])

      puts "FOUND #{gameData.size} - #{ldl.last_keen_date} - #{ldl.last_keen_id}"
      if gameData.size > 0
        gameData.sort_by! { |hsh| hsh['keen']['timestamp'] }
        # puts "ID RANGE: [#{enterScreen.first['keen']['id']} - #{enterScreen.last['keen']['id']}]"
        puts "DATE RANGE: [#{gameData.first['keen']['timestamp']} - #{gameData.last['keen']['timestamp']}]"
      end

      gameData.each do |row|
        if not_test_conditions(row['test'], row['version'])
          keen_date = DateTime.strptime(row['keen']['timestamp'], DATE_FORMAT)

          u_device = UniqueDevice.find_by(device_id: row['userID'])
          u_user = UniqueUser.find_by(user_gplay_id: row['googlePlayUserID'])

          g_e = GameEvent.new
          g_e.unique_device_id = u_device.id if u_device
          g_e.unique_user_id = u_user.id if u_user
          g_e.positiveGameTimeCounter = row['positiveGameTimeCounter']
          g_e.wrongBlockPenaltyCount = row['wrongBlockPenaltyCount']
          g_e.colorName = row['colorName']
          g_e.madnessPointsClicks = row['madnessPointClicks']
          g_e.blockCol = row['blockCol']
          g_e.bombClicks = row['bombClicks']
          g_e.newColorName = row['newColorName']
          g_e.squareStyle = row['squareStyle']
          g_e.speed = row['speed']
          g_e.colorChanges = row['colorChanges']
          g_e.score = row['score']
          g_e.onScreenCount = row['onScreenCount']
          g_e.coinClicks = row['coinClicks']
          g_e.negativeGameTimeCounter = row['negativeGameTimeCounter']
          g_e.onScreenUnclickedCount = row['onScreenUnclickedCount']
          g_e.slowClicks = row['slowClicks']
          g_e.extraPointClicks = row['extraPointClicks']
          g_e.failReason = row['failReason']
          g_e.highscoreFlag = row['highscoreFlag']
          g_e.extraTimeClicks = row['extraTimeClicks']
          g_e.gameTypeName = row['gameTypeName']
          g_e.storedTimeDiff = row['storedTimeDiff']
          g_e.blockRow = row['blockRow']
          g_e.game_at = keen_date
          g_e.thiefClicks = row['thiefClicks']
          g_e.thiefPenaltyCount = row['thiefPenaltYCount']
          g_e.version = row['version']
          g_e.save!
        else
          puts "REJECTED: T:[#{row['test'].inspect}] V:[#{row['version'].inspect}], #{row['test'].nil?}, #{row['test'].is_a?(FalseClass)}, #{row['test'].is_a?(String)}"
        end
      end

      # puts "COUNT - NEW:#{new_c} - UPDATE:#{update_c}"
      #new_t = new_t + new_c
      #update_t = update_t + update_c

      if gameData.size > 0
        ldl.last_keen_id = gameData.last['keen']['id']
        ldl.last_keen_date = DateTime.strptime(gameData.last['keen']['timestamp'], DATE_FORMAT)
        ldl.save!
      end
    end while end_date_s < now_date
    # puts "COUNT - NEW_T:#{new_t} - UPDATE_T:#{update_t}"
    puts "END PROCESS: #{PROCESS_1}"

    puts 'DONE'
  end
end
