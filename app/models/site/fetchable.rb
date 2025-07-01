module Site::Fetchable
  extend ActiveSupport::Concern

  def fetch_website_content
    require "net/http"
    require "uri"

    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Site Snapshotter/1.0"

    response = http.request(request)

    {
      body: response.body,
      status: response.code.to_i,
      headers: response.to_hash
    }
  end
end
