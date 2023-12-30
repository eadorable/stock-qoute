class Stock < ApplicationRecord
  belongs_to :user

  validates :ticker, presence: true, uniqueness: true
  validates :ticker, length: { minimum: 1 }
  validates :ticker, format: { without: /\s|\W|\d|\.\,;\:!?\(\)\[\]/ }
end
