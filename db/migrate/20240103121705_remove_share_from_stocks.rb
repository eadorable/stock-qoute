class RemoveShareFromStocks < ActiveRecord::Migration[7.0]
  def change
    remove_column :stocks, :share, :float
  end
end
