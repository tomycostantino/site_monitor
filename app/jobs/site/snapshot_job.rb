class Site::SnapshotJob < ApplicationJob
  queue_as :default

  def perform(site_id)
    site = Site.find(site_id)
    site.snapshot
  rescue => e
    Rails.logger.error e.message
    raise
  end
end
