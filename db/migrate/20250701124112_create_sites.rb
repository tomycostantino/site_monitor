class CreateSites < ActiveRecord::Migration[8.0]
  def change
    create_table :sites do |t|
      t.string :url, null: false
      t.time :monitor_start_time
      t.time :monitor_end_time
      t.integer :frequency_seconds, default: 60
      t.float :timezone_offset_hours, default: 0.0
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :sites, :url, unique: true
  end
end
