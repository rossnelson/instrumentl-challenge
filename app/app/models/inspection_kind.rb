class InspectionKind < ApplicationRecord
  has_many :inspections, dependent: :destroy
  validates :description, presence: true
end
