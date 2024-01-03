class AddProfitToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :profit, :float
  end
end
