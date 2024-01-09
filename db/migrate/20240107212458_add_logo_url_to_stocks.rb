class AddLogoUrlToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :logo, :string
  end
end
