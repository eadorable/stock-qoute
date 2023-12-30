class AddInvestmentFieldToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :investment, :float
  end
end
