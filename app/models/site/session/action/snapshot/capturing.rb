module Site::Snapshot::Capturing
  extend ActiveSupport::Concern

  included do
    after_create :capture
  end

  private
  def capture
    update!(status: "processing")

    content_data = fetch_website_content

    html_content.attach(
      io: StringIO.new(content_data[:body]),
      filename: "snapshot_#{id}.html",
      content_type: "text/html"
    )

    update!(
      status: content_data[:status] == 200 ? "completed" : "failed",
      response_code: content_data[:status]
    )
  end
end
