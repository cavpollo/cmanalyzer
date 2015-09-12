class CreateLastDataLoads < ActiveRecord::Migration

  def change
    create_table :last_data_loads do |t|
      t.string :process_name, :null => false
      t.date :last_data_load_date, :null => false

      t.timestamps null: false
    end
  end
end
