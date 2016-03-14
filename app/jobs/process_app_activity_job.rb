require 'csv'

class ProcessAppActivityJob < ActiveJob::Base
  queue_as :default

  DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%LZ'
  LAST_DATE_STRING = '2014-06-04T06:00:00.000Z'
  PROCESS_1 = 'ProcessAppActivityJob-gplayactivity'
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
    start_date_s = ldl.last_keen_date
    csv_date = nil
    while start_date_s <= now_date
      puts "Reading CSV #{start_date_s.strftime('%Y-%m')} : tmp/gplay/stats-installs-installs_com.ccs.cm_#{start_date_s.strftime('%Y%m')}_overview.csv"
      CSV.foreach("tmp/gplay/stats-installs-installs_com.ccs.cm_#{start_date_s.strftime('%Y%m')}_overview.csv", encoding: 'UTF-16', col_sep: ',', headers: true, return_headers: false) do |row|
        csv_date = DateTime.strptime(row['Date'], '%Y-%m-%d')
        d_event = DailyEvent.find_by(event_date: csv_date)
        unless d_event
          d_event = DailyEvent.new
          d_event.event_date = csv_date
          d_event.install_count = row['Daily Device Installs'].to_i
          d_event.upgrade_count = row['Daily Device Upgrades'].to_i
          d_event.uninstall_count = row['Daily Device Uninstalls'].to_i
          d_event.save
        end
      end
      start_date_s = start_date_s + 1.month

      #Total Unique users whose date range fits this date
      #Store last date as the Max date form DB
    end
    if csv_date
      ldl.last_keen_id = 0
      ldl.last_keen_date = csv_date
      ldl.save!
    end
    puts "END PROCESS: #{PROCESS_1}"

    ldl = get_ldl(PROCESS_2)
    puts "\nSTART PROCESS: #{PROCESS_2}"
    start_date_s = ldl.last_keen_date - 1.day
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