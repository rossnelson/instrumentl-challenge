class Location < ApplicationRecord
  max_paginates_per 100

  belongs_to :owner
  has_many :inspections, dependent: :destroy
  has_many :violations, dependent: :destroy
  validates :name, presence: true

  scope(
    :search,
    ->(query) { where("search_vector @@ plainto_tsquery('english', ?)", query) }
  )
end
