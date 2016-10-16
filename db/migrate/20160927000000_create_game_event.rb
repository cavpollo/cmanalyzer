class CreateGameEvent < ActiveRecord::Migration
  def change
    create_table :game_events do |t|
      t.float :positiveGameTimeCounter
      t.integer :wrongBlockPenaltyCount
      t.string :colorName
      t.integer :madnessPointsClicks
      t.integer :blockCol
      t.integer :bombClicks
      t.string :newColorName
      t.string :squareStyle
      t.integer :speed
      t.integer :colorChanges
      t.integer :score
      t.integer :onScreenCount
      t.integer :coinClicks
      t.float :negativeGameTimeCounter
      t.integer :onScreenUnclickedCount
      t.integer :slowClicks
      t.integer :extraPointClicks
      t.string :failReason
      t.boolean :highscoreFlag
      t.integer :extraTimeClicks
      t.string :gameTypeName
      t.integer :storedTimeDiff
      t.integer :blockRow
      t.datetime :game_at
      t.integer :thiefClicks
      t.integer :thiefPenaltyCount
      t.string :version
      t.references :unique_device
      t.references :unique_user
      
      t.timestamps null: false
    end
  end
end
