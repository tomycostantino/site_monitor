require "test_helper"
require "webmock/minitest"

class SiteTest < ActiveSupport::TestCase
  def setup
    @valid_site = sites(:valid_site)
    @google_site = sites(:google)
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  def teardown
    WebMock.reset!
  end

  test "should be valid with valid attributes" do
    stub_request(:get, "https://www.example.com")
      .to_return(status: 200, body: "<html></html>")

    site = Site.new(
      url: "https://www.example.com",
      frequency_seconds: 60
    )

    assert site.valid?
  end

  test "should require url" do
    site = Site.new(frequency_seconds: 60)

    assert_not site.valid?
    assert_includes site.errors[:url], "can't be blank"
  end

  test "should give an error when frequency_seconds is set to nil" do
    stub_request(:get, "https://www.example.com")
      .to_return(status: 200, body: "<html></html>")

    site = Site.new(url: "https://www.example.com", frequency_seconds: nil)

    assert_not site.valid?
    assert_includes site.errors[:frequency_seconds], "can't be blank"
    end

  test "should set frequency_seconds to 60 if not in params" do
    stub_request(:get, "https://www.example.com")
      .to_return(status: 200, body: "<html></html>")

    site = Site.new(url: "https://www.example.com")

    assert site.valid?
    assert site.frequency_seconds == 60
  end

  test "should validate url format" do
    invalid_urls = %w[not-a-url ftp://example.com invalid://example.com www.example.com example.com]

    invalid_urls.each do |invalid_url|
      site = Site.new(url: invalid_url, frequency_seconds: 60)

      assert_not site.valid?
      assert_includes site.errors[:url], "is invalid"
    end
  end

  test "should accept valid url formats" do
    valid_urls = %w[http://example.com https://example.com https://www.example.com http://subdomain.example.com https://example.com/path]

    valid_urls.each do |valid_url|
      stub_request(:get, valid_url)
        .to_return(status: 200, body: "<html></html>")

      site = Site.new(url: valid_url, frequency_seconds: 60)

      assert site.valid?
    end
  end

  test "should validate url is reachable when site returns 200" do
    stub_request(:get, "https://reachable-site.com")
      .to_return(status: 200, body: "<html></html>")

    site = Site.new(
      url: "https://reachable-site.com",
      frequency_seconds: 60
    )

    assert site.valid?
  end

  test "should not validate url when site is unreachable" do
    stub_request(:get, "https://unreachable-site.com")
      .to_return(status: 404, body: "Not Found")

    site = Site.new(
      url: "https://unreachable-site.com",
      frequency_seconds: 60
    )

    assert_not site.valid?
    assert_includes site.errors[:url], "is not reachable"
  end

  test "should not validate url when network error occurs" do
    stub_request(:get, "https://error-site.com")
      .to_raise(SocketError.new("Network error"))

    site = Site.new(
      url: "https://error-site.com",
      frequency_seconds: 60
    )

    assert_not site.valid?
    assert_includes site.errors[:url], "is not reachable"
  end

  test "should have many snapshots" do
    assert_respond_to @valid_site, :snapshots
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @valid_site.snapshots
  end

  test "should have default values" do
    site = Site.new(url: "https://example.com")
    assert_equal 60, site.frequency_seconds
    assert_equal 0, site.timezone_offset_hours
    assert_equal true, site.active
  end


  test "should fetch website content successfully" do
    expected_body = "<html><head><title>Test</title></head><body>Test Content</body></html>"
    expected_headers = {
      "content-type" => [ "text/html; charset=utf-8" ],
      "content-length" => [ "123" ]
    }

    stub_request(:get, @valid_site.url)
      .with(headers: { "User-Agent" => "Site Snapshotter/1.0" })
      .to_return(
        status: 200,
        body: expected_body,
        headers: expected_headers
      )

    result = @valid_site.fetch_website_content

    assert_equal expected_body, result[:body]
    assert_equal 200, result[:status]
    assert_equal expected_headers, result[:headers]
  end

  test "should handle HTTP errors when fetching content" do
    stub_request(:get, @valid_site.url)
      .to_return(status: 404, body: "Not Found")

    result = @valid_site.fetch_website_content

    assert_equal "Not Found", result[:body]
    assert_equal 404, result[:status]
  end

  test "should set proper user agent header" do
    stub_request(:get, @valid_site.url)
      .with(headers: { "User-Agent" => "Site Snapshotter/1.0" })
      .to_return(status: 200, body: "OK")

    result = @valid_site.fetch_website_content

    assert_equal "OK", result[:body]
    assert_equal 200, result[:status]
  end

  test "should be reachable when site returns 200 status" do
    stub_request(:get, @valid_site.url)
      .to_return(status: 200, body: "<html></html>")

    assert @valid_site.reachable?
  end

  test "should not be reachable when site returns non-200 status" do
    stub_request(:get, @valid_site.url)
      .to_return(status: 404, body: "Not Found")

    assert_not @valid_site.reachable?
  end

  test "should not be reachable when network error occurs" do
    stub_request(:get, @valid_site.url)
      .to_raise(SocketError.new("Network error"))

    assert_not @valid_site.reachable?
  end

  test "should not be reachable when timeout occurs" do
    stub_request(:get, @valid_site.url)
      .to_timeout

    assert_not @valid_site.reachable?
  end

  test "should enforce unique url constraint" do
    stub_request(:get, @valid_site.url)
      .to_return(status: 200, body: "<html></html>")

    duplicate_site = Site.new(
      url: @valid_site.url,
      frequency_seconds: 120
    )

    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_site.save!
    end
  end

  test "should create site with all attributes" do
    url = "https://www.ruby-lang.org"

    stub_request(:get, url)
      .to_return(status: 200, body: "<html></html>")

    site = Site.create!(
      url: url,
      monitor_start_time: "08:00:00",
      monitor_end_time: "09:00:00",
      frequency_seconds: 300,
      timezone_offset_hours: -5,
      active: false
    )

    assert_equal url, site.url
    assert_equal 300, site.frequency_seconds
    assert_equal(-5, site.timezone_offset_hours)
    assert_equal false, site.active
    assert_not_nil site.monitor_start_time
    assert_not_nil site.monitor_end_time
    assert_not_nil site.created_at
    assert_not_nil site.updated_at
  end

  test "should update site attributes" do
    stub_request(:get, @valid_site.url)
      .to_return(status: 200, body: "<html></html>")

    @valid_site.update!(
      frequency_seconds: 900,
      active: false
    )

    assert_equal 900, @valid_site.frequency_seconds
    assert_equal false, @valid_site.active
  end

  test "should handle HTTPS sites properly" do
    https_url = "https://secure.example.com"

    stub_request(:get, https_url)
      .to_return(status: 200, body: "<html></html>")

    site = Site.new(url: https_url, frequency_seconds: 60)

    assert site.valid?
    assert site.reachable?
  end

  test "should handle sites with ports" do
    url_with_port = "https://example.com:8080"

    stub_request(:get, url_with_port)
      .to_return(status: 200, body: "<html></html>")

    site = Site.new(url: url_with_port, frequency_seconds: 60)

    assert site.valid?
    assert site.reachable?
  end
end
