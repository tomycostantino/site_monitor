module Site::Snapshotable
  extend ActiveSupport::Concern
  include Site::Fetchable

  def snapshot
    s = snapshots.create!(captured_at: Time.now)
    process_snapshot(s)
    s
  rescue => e
    Rails.logger.error e.message
    s&.update(status: "failed", error_message: e.message)
    raise
  end

  private

  def process_snapshot(snapshot)
    snapshot.update!(status: "processing")

    content_data = fetch_website_content

    snapshot.html_content.attach(
      io: StringIO.new(content_data[:body]),
      filename: "snapshot_#{snapshot.id}.html",
      content_type: "text/html"
    )

    snapshot.update!(
      status: content_data[:status] == 200 ? "completed" : "failed",
      response_code: content_data[:status]
    )
  end
end
