class CreateUniqueUsers < ActiveRecord::Migration
  #Data slurped from ScreenProperties & GooGlePlayInfo
  def change
    create_table :unique_users do |t|
      t.references :unique_device, :null => false
      t.string :user_gplay_id, :null => false
      t.string :user_gender, :null => false
      t.string :user_language, :null => false
      t.date :first_play_date, :null => false
      t.date :last_play_date, :null => false

      t.timestamps null: false
    end
  end
end
