class Site::Session < ApplicationRecord
  belongs_to :site
  has_many :actions, dependent: :destroy
end
