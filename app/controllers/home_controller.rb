class HomeController < ApplicationController

  def about
  end

  def index
    ticker = 'aapl' # Replace with the stock symbol you want to fetch
    symbol = ticker.upcase
    polygon_service = PolygonService.new(ENV['POLYGON_API_KEY'])
    @quote = polygon_service.get_stock_quote(symbol)

    if @quote && @quote['results'].present? && @quote['results'][0]['T'].present? && @quote['results'][0]['c'].present?
      @stock_name = @quote['results'][0]['T']
      @stock_price = @quote['results'][0]['c']
    else
      flash.now[:alert] = 'Error fetching stock quote. Please check the stock symbol.'
    end

  end
end
