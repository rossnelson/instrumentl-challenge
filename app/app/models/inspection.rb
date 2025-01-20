class Inspection < ApplicationRecord
  belongs_to :inspection_kind
  belongs_to :location
  has_many :violations, dependent: :destroy
  validates :occurred_at, presence: true
end
