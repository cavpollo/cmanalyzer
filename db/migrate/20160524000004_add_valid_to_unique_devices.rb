class AddValidToUniqueDevices < ActiveRecord::Migration
  def change
    add_column :unique_devices, :valid_device, :boolean, null: false, default: true
  end
end