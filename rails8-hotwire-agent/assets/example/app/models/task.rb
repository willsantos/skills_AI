class Task < ApplicationRecord
  belongs_to :user

  normalizes :title, with: ->(value) { value.strip }
  validates :title, presence: true, length: { maximum: 200 }
end
