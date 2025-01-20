class RiskCategory < ApplicationRecord
  has_many :violations, dependent: :destroy
  validates :name, presence: true
end
