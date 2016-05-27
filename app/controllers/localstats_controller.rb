class LocalstatsController < ApplicationController
  def index

  end

  def devices
    @brands_count = UniqueDevice.count()

    min_brand_count = 40
    brands_count = UniqueDevice.group(:device_brand).order(:device_brand).count()
    @brands = brands_count.reject { |key, value| value <= min_brand_count || key.empty? }
  end

  def devices_data
    min_brand_count = 40
    brands_count = UniqueDevice.group(:device_brand).order(:device_brand).count()
    brands = brands_count.reject { |key, value| value <= min_brand_count }
    brands["Other (<= #{min_brand_count})"] = brands_count.reject { |key, value| value > min_brand_count }.collect{ |key, value| value }.sum

    if params[:brand].nil? || params[:brand].empty?
      min_percentage = 3/100.0 #7.5%
      models_count = UniqueDevice.group(:device_model).order(:device_model).count()
      min_model_count = (models_count.size*min_percentage).ceil
      models = models_count.reject { |key, value| value <= min_model_count }
      models["Other (<= #{min_model_count})"] = models_count.reject { |key, value| value > min_model_count }.collect{ |key, value| value }.sum
    else
      min_percentage = 7.5/100.0 #7.5%
      models_count = UniqueDevice.where(device_brand: params[:brand]).group(:device_model).order(:device_model).count()
      min_model_count = (models_count.size*min_percentage).ceil
      models = models_count.reject { |key, value| value <= min_model_count }
      models["Other (<= #{min_model_count})"] = models_count.reject { |key, value| value > min_model_count }.collect{ |key, value| value }.sum
    end

    respond_to do |format|
      format.html { render :devices }
      format.json { render json: {brands: brands, models: models}, status: :ok }
    end
  end

  def app_activity

  end

  def app_activity_data
    users_start_date = UniqueDevice.order('DATE(first_play_date)').group('DATE(first_play_date)').count
    users_last_date = UniqueDevice.order('DATE(last_play_date)').group('DATE(last_play_date)').count
    users_firstlast_date = UniqueDevice.where('first_play_date = last_play_date').order('DATE(last_play_date)').group('DATE(last_play_date)').count

    start_date = Date.new(2014, 06, 03)
    now_date = Time.zone.now
    dates = []
    first_plays = []
    last_plays = []
    firstlast_plays = []
    installs = []
    upgrade = []
    uninstall = []
    # active = []

    # daily_array = []
    # week_number = -1
    # week_count = 0
    # weekly_array = []
    # month_number = -1
    # month_count = 0
    # monthly_array = []

    while start_date < now_date
      dates << start_date.strftime('%Y-%m-%d')
      first_plays << (users_start_date[start_date] || 0)
      last_plays << (users_last_date[start_date] || 0)
      firstlast_plays << (users_firstlast_date[start_date] || 0)

      d_event = DailyEvent.find_by(event_date: start_date)
      installs << (d_event ? d_event.install_count : 0)
      upgrade << (d_event ? d_event.upgrade_count : 0)
      uninstall << (d_event ? d_event.uninstall_count : 0)
      # active << (d_event ? d_event.active_users_count : 0)

      # daily_array << (d_event ? d_event.install_count : 0)
      # if week_number != start_date.cweek
      #   week_count = week_count + (d_event ? d_event.install_count : 0)
      # else
      #   weekly_array << week_count
      #   week_count = 0
      # end
      # if month_number != start_date.month
      #   month_count = month_count + (d_event ? d_event.install_count : 0)
      # else
      #   monthly_array << month_count
      #   month_count = 0
      # end

      start_date = start_date + 1.day
    end

    users_days_of_use = ActiveRecord::Base.connection.execute('SELECT days_of_use, COUNT(*) AS count FROM
        (SELECT (last_play_date - first_play_date + 1) AS days_of_use FROM unique_devices) my_table
      GROUP BY days_of_use
      ORDER BY days_of_use ASC;').map { |r| [r['days_of_use'].to_i, r['count'].to_i, r['days_of_use'].to_i == 1 ? 0 : r['count'].to_i] }

    users_days_of_use_list = ActiveRecord::Base.connection.execute('SELECT (last_play_date - first_play_date + 1) AS days_of_use FROM unique_devices WHERE (last_play_date - first_play_date + 1) > 1 ORDER BY days_of_use ASC;').collect { |r| r['days_of_use'].to_i }
    users_median_days_of_use = (users_days_of_use_list[(users_days_of_use_list.length - 1) / 2] + users_days_of_use_list[users_days_of_use_list.length / 2]) / 2.0
    users_average_days_of_use = ActiveRecord::Base.connection.execute('SELECT AVG(last_play_date - first_play_date + 1) AS count FROM unique_devices;').collect { |r| r['count'].to_i }
    users_above_average_days_of_use = ActiveRecord::Base.connection.execute("SELECT COUNT(*) AS count FROM unique_devices WHERE (last_play_date - first_play_date + 1) > #{users_average_days_of_use[0]};").collect { |r| r['count'].to_i }

    # daily_average = daily_array.inject(:+).to_f / daily_array.size
    # weekly_average = weekly_array.inject(:+).to_f / weekly_array.size
    # monthly_average = monthly_array.inject(:+).to_f / monthly_array.size

    respond_to do |format|
      format.html { render :app_activity }
      format.json { render json: {users_start_date: [dates, first_plays, last_plays, firstlast_plays, installs, upgrade, uninstall],
                                  users_day_of_use: users_days_of_use, users_average_days_of_use: users_average_days_of_use[0],
                                  users_above_average_days_of_use: users_above_average_days_of_use[0], users_median_days_of_use: users_median_days_of_use}, status: :ok }
                                  # daily_average: daily_average, weekly_average: weekly_average, monthly_average: monthly_average}
    end
  end

  def loss_activity
    #To generate lists for correlation stuff...

    # query = 'SELECT device_height / device_width AS prop, (last_play_date - first_play_date + 1) AS days_of_use
    # FROM unique_devices
    # WHERE (last_play_date - first_play_date) > 3
    # ORDER BY days_of_use ASC, prop ASC;'
    # ratio_count = ActiveRecord::Base.connection.execute(query).collect { |r| [r['prop'].to_f, r['days_of_use'].to_i] }
    # puts ratio_count.inspect
    # puts ratio_count.transpose.inspect

    # query = 'SELECT device_height, (last_play_date - first_play_date + 1) AS days_of_use
    # FROM unique_devices
    # WHERE (last_play_date - first_play_date) > 65
    # ORDER BY days_of_use ASC, prop ASC;'
    # h_count = ActiveRecord::Base.connection.execute(query).collect { |r| [r['prop'].to_f, r['device_height'].to_i] }
    # puts h_count.inspect
    # puts h_count.transpose.inspect
  end

  def loss_activity_data
    query = 'SELECT A.device_density, COUNT(A.*) AS count, (SELECT COUNT(*) FROM unique_devices AS B WHERE B.valid_device = TRUE AND B.device_density = A.device_density AND (last_play_date - first_play_date) = 0) AS count_one_day FROM unique_devices AS A GROUP BY A.device_density ORDER BY A.device_density ASC;'
    ratio_count = ActiveRecord::Base.connection.execute(query).map { |r| [r['device_density'], r['count'].to_i, r['count_one_day'].to_i] }

    query = 'SELECT device_density, (last_play_date - first_play_date + 1) AS days_of_use, COUNT(*) AS count FROM unique_devices GROUP BY days_of_use, device_density ORDER BY days_of_use ASC, device_density ASC;'
    ratio_vs_days_of_use = ActiveRecord::Base.connection.execute(query).collect { |r| {x: r['device_density'].to_f, y: r['days_of_use'].to_i, z: r['count'].to_i} }

    query = 'SELECT A.prop, COUNT(A.*) AS count, (SELECT COUNT(*) FROM unique_devices AS B WHERE B.valid_device = TRUE AND (B.device_height / B.device_width) = A.prop AND (last_play_date - first_play_date) = 0) AS count_one_day FROM (SELECT device_height / device_width AS prop FROM unique_devices WHERE valid_device = TRUE) AS A GROUP BY A.prop ORDER BY A.prop ASC;'
    prop_count = (ActiveRecord::Base.connection.execute(query).collect { |r| [r['prop'].to_f.round(4), r['count'].to_i, r['count_one_day'].to_i] if r['count'].to_i > 6 }).compact

    query = 'SELECT device_height / device_width AS prop, (last_play_date - first_play_date + 1) AS days_of_use, COUNT(*) AS count FROM unique_devices WHERE valid_device = TRUE AND (device_height / device_width) >= 1 GROUP BY days_of_use, prop ORDER BY days_of_use ASC, prop ASC;'
    prop_vs_days_of_use = ActiveRecord::Base.connection.execute(query).collect { |r| {x: r['prop'].to_f.round(4), y: r['days_of_use'].to_i, z: r['count'].to_i} }

    query = 'SELECT A.device_height, COUNT(A.*) AS count, (SELECT COUNT(*) FROM unique_devices AS B WHERE B.valid_device = TRUE AND B.device_height = A.device_height AND (last_play_date - first_play_date) = 0) AS count_one_day FROM unique_devices AS A GROUP BY A.device_height ORDER BY A.device_height ASC;'
    h_count = (ActiveRecord::Base.connection.execute(query).collect { |r| [r['device_height'].to_f.round(4), r['count'].to_i, r['count_one_day'].to_i] if r['count'].to_i > 6 }).compact

    query = 'SELECT device_height, (last_play_date - first_play_date + 1) AS days_of_use, COUNT(*) AS count FROM unique_devices WHERE valid_device = TRUE AND (device_height / device_width) >= 1 GROUP BY days_of_use, device_height ORDER BY days_of_use ASC, device_height ASC;'
    h_vs_days_of_use = ActiveRecord::Base.connection.execute(query).collect { |r| {x: r['device_height'].to_f.round(4), y: r['days_of_use'].to_i, z: r['count'].to_i} }

    query = 'SELECT Z.days, avg(Z.access_count) AS average FROM (SELECT (unique_devices.last_play_date - unique_devices.first_play_date + 1) as days, access_count FROM user_screen_events JOIN unique_devices ON unique_devices.id = user_screen_events.unique_device_id WHERE screen_name = \'MenuScreen\') Z GROUP BY Z.days ORDER BY Z.days ASC;'
    screen_menu = ActiveRecord::Base.connection.execute(query).map { |r| [r['days'].to_i, r['average'].to_f.round(4)] }

    query = 'SELECT Z.days, avg(Z.access_count) AS average FROM (SELECT (unique_devices.last_play_date - unique_devices.first_play_date + 1) as days, access_count FROM user_screen_events JOIN unique_devices ON unique_devices.id = user_screen_events.unique_device_id WHERE screen_name = \'HelpScreen\') Z GROUP BY Z.days ORDER BY Z.days ASC;'
    screen_help = ActiveRecord::Base.connection.execute(query).map { |r| [r['days'].to_i, r['average'].to_f.round(4)] }

    query = 'SELECT Z.days, avg(Z.access_count) AS average FROM (SELECT (unique_devices.last_play_date - unique_devices.first_play_date + 1) as days, access_count FROM user_screen_events JOIN unique_devices ON unique_devices.id = user_screen_events.unique_device_id WHERE screen_name = \'StatScreen\') Z GROUP BY Z.days ORDER BY Z.days ASC;'
    screen_stat = ActiveRecord::Base.connection.execute(query).map { |r| [r['days'].to_i, r['average'].to_f.round(4)] }

    query = 'SELECT Z.days, avg(Z.access_count) AS average FROM (SELECT (unique_devices.last_play_date - unique_devices.first_play_date + 1) as days, access_count FROM user_screen_events JOIN unique_devices ON unique_devices.id = user_screen_events.unique_device_id WHERE screen_name = \'ShopScreen\') Z GROUP BY Z.days ORDER BY Z.days ASC;'
    screen_shop = ActiveRecord::Base.connection.execute(query).map { |r| [r['days'].to_i, r['average'].to_f.round(4)] }

    query = 'SELECT day, access_count FROM user_screen_days WHERE screen_name = \'CreditScreen\' ORDER BY day ASC;'
    days_cred = ActiveRecord::Base.connection.execute(query).map { |r| [r['day'].to_i, r['access_count'].to_i] }

    query = 'SELECT day, access_count FROM user_screen_days WHERE screen_name = \'PhotoScreen\' ORDER BY day ASC;'
    days_phot = ActiveRecord::Base.connection.execute(query).map { |r| [r['day'].to_i, r['access_count'].to_i] }

    query = 'SELECT day, access_count FROM user_screen_days WHERE screen_name = \'HelpScreen\' ORDER BY day ASC;'
    days_help = ActiveRecord::Base.connection.execute(query).map { |r| [r['day'].to_i, r['access_count'].to_i] }

    query = 'SELECT day, access_count FROM user_screen_days WHERE screen_name = \'StatScreen\' ORDER BY day ASC;'
    days_stat = ActiveRecord::Base.connection.execute(query).map { |r| [r['day'].to_i, r['access_count'].to_i] }

    query = 'SELECT day, access_count FROM user_screen_days WHERE screen_name = \'ShopScreen\' AND day <= 150 ORDER BY day ASC;'
    days_shop = ActiveRecord::Base.connection.execute(query).map { |r| [r['day'].to_i, r['access_count'].to_i] }

    query = 'SELECT day, access_count FROM user_screen_days WHERE screen_name = \'Achievements\' ORDER BY day ASC;'
    days_achi = ActiveRecord::Base.connection.execute(query).map { |r| [r['day'].to_i, r['access_count'].to_i] }

    query = 'SELECT day, access_count FROM user_screen_days WHERE screen_name = \'Leaderboards\' ORDER BY day ASC;'
    days_lead = ActiveRecord::Base.connection.execute(query).map { |r| [r['day'].to_i, r['access_count'].to_i] }

    # query = 'SELECT Z.screen_name, Z.days, avg(Z.access_count) AS average FROM (SELECT screen_name, (unique_devices.last_play_date - unique_devices.first_play_date + 1) as days, access_count FROM user_screen_events JOIN unique_devices ON unique_devices.id = user_screen_events.unique_device_id WHERE screen_name IN
    # (\'StatScreen\',\'Leaderboards\',\'CreditScreen\',\'PhotoScreen\',\'ShopScreen\',\'Achievements\',\'HelpScreen\')) Z GROUP BY Z.screen_name, Z.days ORDER BY Z.screen_name ASC, Z.days ASC;'

    respond_to do |format|
      format.html { render :loss_activity }
      format.json { render json: {ratio_count: ratio_count,
                                  ratio_vs_days_of_use: ratio_vs_days_of_use,
                                  prop_count: prop_count,
                                  prop_vs_days_of_use: prop_vs_days_of_use,
                                  h_count: h_count,
                                  h_vs_days_of_use: h_vs_days_of_use,
                                  screen_menu: screen_menu,
                                  screen_help: screen_help,
                                  screen_stat: screen_stat,
                                  screen_shop: screen_shop,
                                  days_cred: days_cred,
                                  days_phot: days_phot,
                                  days_help: days_help,
                                  days_stat: days_stat,
                                  days_shop: days_shop,
                                  days_achi: days_achi,
                                  days_lead: days_lead}, status: :ok }
    end
  end
end
