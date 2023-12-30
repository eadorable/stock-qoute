class AddCompanyNameandPriceToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :name, :string
    add_column :stocks, :price, :float
  end
end
