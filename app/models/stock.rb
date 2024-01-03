class Stock < ApplicationRecord
  belongs_to :user

  validates :ticker, presence: true, uniqueness: { scope: :user_id },
                     format: { without: /\s|\W|\d|\.\,;\:!?\(\)\[\]/ }

  validates :buy_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :investment, presence: true, numericality: { greater_than: 0 }

end
