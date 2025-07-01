class CreateSiteSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :site_snapshots do |t|
      t.references :site, null: false, foreign_key: true
      t.string :status
      t.integer :response_code
      t.text :error_message
      t.string :captured_at

      t.timestamps
    end
  end
end
