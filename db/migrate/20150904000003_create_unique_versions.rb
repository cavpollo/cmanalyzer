class CreateUniqueVersions < ActiveRecord::Migration
  #Data slurped from ScreenProperties
  def change
    create_table :unique_versions do |t|
      t.references :unique_device, null: false
      t.string :game_version, null: false
      t.integer :play_count, null: false
      t.date :first_play_date, null: false
      t.date :last_play_date, null: false

      t.timestamps null: false
    end
  end
end
