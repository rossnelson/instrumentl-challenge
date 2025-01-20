class ViolationKind < ApplicationRecord
  has_many :violations, dependent: :destroy
  validates :code, presence: true
end
