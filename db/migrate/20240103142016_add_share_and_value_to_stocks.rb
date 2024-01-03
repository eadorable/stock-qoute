class AddShareAndValueToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :share, :float
    add_column :stocks, :value, :float
  end
end
