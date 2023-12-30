class AddBuyPriceAndSharesFieldToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :buy_price, :float
    add_column :stocks, :share, :float
  end
end
