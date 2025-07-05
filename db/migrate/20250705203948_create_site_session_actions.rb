class CreateSiteSessionActions < ActiveRecord::Migration[8.0]
  def change
    create_table :site_session_actions do |t|
      t.references :site_sessions, null: false, foreign_key: true
      t.string :name
      t.json :query_params
      t.json :data
      t.string :kind
      t.integer :order
      t.integer :wait_seconds, default: 0
      t.boolean :record_response, default: true

      t.timestamps
    end
  end
end
