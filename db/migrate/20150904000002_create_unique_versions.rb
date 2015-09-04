class CreateUniqueVersions < ActiveRecord::Migration
  #Data slurped from ScreenProperties
  def change
    create_table :unique_versions do |t|
      t.references :unique_user, :null => false
      t.string :game_version, :null => false

      t.timestamps null: false
    end
  end
end
