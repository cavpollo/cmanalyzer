class CreateUserScreenDays < ActiveRecord::Migration
  def change
    create_table :user_screen_days do |t|
      t.string :screen_name, null: false
      t.integer :day, null: false, default: 0
      t.integer :access_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
