class Site < ApplicationRecord
  has_many :snapshots
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :frequency_seconds, presence: true
end
