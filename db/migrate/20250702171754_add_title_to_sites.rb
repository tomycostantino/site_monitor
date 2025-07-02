class AddTitleToSites < ActiveRecord::Migration[8.0]
  def change
    add_column :sites, :title, :string
  end
end
