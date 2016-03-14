class ProcessAppActivityJob < ActiveJob::Base
  queue_as :default

  DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%LZ'
  LAST_DATE_STRING = '2014-07-24T06:00:00.000Z'
  DATE_STEP = 1.day
  PROCESS_1 = 'ProcessAppActivityJob-rangeactivity'
  PROCESS_2 = 'ProcessAppActivityJob-dailyactivity'

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
    begin
      #Total Unique users whose date range fits this date
      #Store last date as the Max date form DB
    end
    puts "END PROCESS: #{PROCESS_1}"

    ldl = get_ldl(PROCESS_2)
    puts "\nSTART PROCESS: #{PROCESS_2}"
    start_date_s = ldl.last_keen_date - DATE_STEP
    begin
      #Total Unique Users playing this day

      #Total Games Played This day

      #Total times each mode is played (like 6 cols)
      #Total times each mode is played by an user (1 or 0 per user)
      #Avergae game modes played/tested per user
      #Total games grouped by hour
      #Total games grouped by day
      #Total games grouped by week
    end
    puts "END PROCESS: #{PROCESS_2}"

    puts 'DONE'
  end
end