class CreateUserScreenEvents < ActiveRecord::Migration
  def change
    create_table :user_screen_events do |t|
      t.references :unique_device, null: false
      t.string :screen_name, null: false
      t.date :first_date, null: false
      t.date :last_date, null: false
      t.integer :access_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
