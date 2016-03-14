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

    start_date = Date.new(2014, 06, 03)
    now_date = Time.zone.now
    dates = []
    values = []
    while start_date < now_date
      dates << start_date.strftime('%Y-%m-%d')
      values << (users_start_date[start_date] || 0)

      start_date = start_date + 1.day
    end

    respond_to do |format|
      format.html { render :app_activity }
      format.json { render json: {users_start_date: [dates, values]}, status: :ok }
    end
  end
end
