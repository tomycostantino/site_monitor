class CreateSites < ActiveRecord::Migration[8.0]
  def change
    create_table :sites do |t|
      t.string :url, unique: true, null: false
      t.datetime :start_time
      t.datetime :end_time
      t.integer :frequency_seconds, default: 60.seconds
      t.integer :timezone_offset, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :sites, :url
  end
end
