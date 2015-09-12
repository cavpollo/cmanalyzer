class CreateUniqueDevices < ActiveRecord::Migration

  def change
    create_table :last_data_load do |t|
      t.string :model_name, :null => false
      t.date :date_load, :null => false

      t.timestamps null: false
    end
  end
end
