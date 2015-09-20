class AddDeviceVarsToUniqueDevices < ActiveRecord::Migration
  def up
    add_column :unique_devices, :device_brand, :string, :null => false, :default => ''
    add_column :unique_devices, :device_name, :string, :null => false, :default => ''
  end
end