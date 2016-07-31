class CreateScreenUserDays < ActiveRecord::Migration
  def change
    create_table :screen_user_days do |t|
      t.references :unique_device, null: false, default: 0
      t.references :unique_user, null: false, default: 0
      t.string :screen_name, null: false
      t.integer :day, null: false, default: 0
      t.integer :access_count, null: false, default: 0
      t.string :version, null: false

      t.timestamps null: false
    end
  end
end
