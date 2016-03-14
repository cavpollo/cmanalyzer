class CreateDailyEvents < ActiveRecord::Migration
  def change
    create_table :daily_events do |t|
      t.date :event_date, null: false
      t.integer :install_count, null: false, default: 0
      t.integer :upgrade_count, null: false, default: 0
      t.integer :uninstall_count, null: false, default: 0
      t.integer :active_users_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
