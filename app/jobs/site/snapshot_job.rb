class Site::SnapshotJob < ApplicationJob
  queue_as :default

  def perform(site)
    site.snapshot
  rescue => e
    Rails.logger.error e.message
    raise
  end
end
