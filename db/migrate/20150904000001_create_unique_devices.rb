class CreateUniqueDevices < ActiveRecord::Migration
  #http://stackoverflow.com/questions/885188/specific-time-range-query-in-sql-server
  #Data slurped from ScreenProperties
  def change
    create_table :unique_devices do |t|
      t.string :device_id, :null => false
      t.float :device_density, :null => false
      t.float :device_height, :null => false
      t.float :device_width, :null => false
      t.float :device_h_diff, :null => false
      t.date :first_play_date, :null => false
      t.date :last_play_date, :null => false

      t.timestamps null: false
    end
  end
end
