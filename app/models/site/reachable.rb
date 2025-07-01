module Site::Reachable
  extend ActiveSupport::Concern
  include Site::Fetchable

  def reachable?
    begin
      result = fetch_website_content
      result[:status] == 200
    rescue
      false
    end
  end
end
