class LocalstatsController < ApplicationController
  def index

  end

  def app_access
  end

  def app_access_data

  end

  def devices
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
end
