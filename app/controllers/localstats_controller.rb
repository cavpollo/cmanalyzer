class LocalstatsController < ApplicationController
  def app_access
  end

  def app_access_data

  end

  def devices
  end

  def devices_data
    min_brand_count = 20
    brands_count = UniqueDevice.group(:device_brand).order(:device_brand).count()
    brands = brands_count.reject { |key, value| value <= min_brand_count }
    brands["Other (less than #{min_brand_count})"] = brands_count.reject { |key, value| value > min_brand_count }.collect{ |key, value| value }.sum

    min_model_count = 13
    models_count = UniqueDevice.group(:device_model).order(:device_model).count()
    models = models_count.reject { |key, value| value <= min_model_count }
    models["Other (less than #{min_model_count})"] = models_count.reject { |key, value| value > min_model_count }.collect{ |key, value| value }.sum

    respond_to do |format|
      format.html { render :devices }
      format.json { render json: {brands: brands, models: models}, status: :ok }
    end
  end
end
