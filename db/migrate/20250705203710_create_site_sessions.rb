class CreateSiteSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :site_sessions do |t|
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end
  end
end
