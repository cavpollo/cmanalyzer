class CreateLastDataLoads < ActiveRecord::Migration

  def change
    create_table :last_data_loads do |t|
      t.string :process_name, null: false
      t.string :last_keen_date, null: false
      t.string :last_keen_id, null: false

      t.timestamps null: false
    end
  end
end
