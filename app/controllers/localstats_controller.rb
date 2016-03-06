class LocalstatsController < ApplicationController
  def app_access
  end

  def app_access_data

  end

  def devices
  end

  def devices_data
    # SELECT COUNT(*) AS count_all, device_brand AS device_brand FROM "unique_devices" GROUP BY "unique_devices"."device_brand"  ORDER BY count_all desc
    brands = UniqueDevice.group(:device_brand).order(:device_brand).count()
    # SELECT COUNT(*) AS count_all, device_model AS device_model FROM "unique_devices" GROUP BY "unique_devices"."device_model"  ORDER BY count_all desc
    min_count = 10
    models_count = UniqueDevice.group(:device_model).order(:device_model).count()
    models = models_count.reject { |key, value| value <= min_count }
    models["Other (less than #{min_count})"] = models_count.reject { |key, value| value > min_count }.collect{ |key, value| value }.sum

    respond_to do |format|
      format.html { render :devices }
      format.json { render json: {brands: brands, models: models}, status: :ok }
    end
  end
end
