class Site::Snapshot < ApplicationRecord
  include Capturing

  STATUS = %w[pending processing completed failed]
  enum :status, STATUS.zip(STATUS).to_h, default: STATUS.first

  belongs_to :site
  has_one_attached :html_content
  has_one_attached :image_content

  validates :status, presence: true
end
