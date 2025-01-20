class Violation < ApplicationRecord
  belongs_to :violation_kind
  belongs_to :inspection
  belongs_to :location
  belongs_to :risk_category
  validates :occurred_at, presence: true
  validates :description, presence: true
end
