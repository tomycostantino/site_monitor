class Site::SnapshotsController < ApplicationController
  before_action :set_site, only: [ :create ]
  def create
    Site::SnapshotJob.perform_later(@site)
    redirect_to @site, notice: "Snapshot was successfully created."
  end

  private
  def set_site
    @site = Site.find(params[:site_id])
  end
end
