class RenameSiteSnapshotsToSiteSessionActionSnapshots < ActiveRecord::Migration[8.0]
  def change
    rename_table :site_snapshots, :site_session_action_snapshots

    rename_column :site_session_action_snapshots, :site_id, :site_session_action_id
    remove_column :site_session_action_snapshots, :created_at

    remove_foreign_key :site_session_action_snapshots, :sites
    add_foreign_key :site_session_action_snapshots, :site_session_actions
  end
end
