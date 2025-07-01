class Site::Snapshot < ApplicationRecord
  STATUS = %w[pending processing completed failed]

  belongs_to :site
  has_one_attached :html_content
  has_one_attached :image_content

  validates :status, presence: true
  enum :status, STATUS.zip(STATUS).to_h, default: STATUS.first
end
