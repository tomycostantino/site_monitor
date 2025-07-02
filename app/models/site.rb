class Site < ApplicationRecord
  include Fetchable
  include Reachable
  include Snapshots

  has_many :snapshots
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :frequency_seconds, presence: true
  validate :can_be_reached?

  private
  def can_be_reached?
    unless reachable?
      errors.add(:url, "is not reachable")
    end
  end
end
