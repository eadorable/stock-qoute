class StocksController < ApplicationController
  before_action :set_stock, only: %i[ show edit update destroy ]
  before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!

  require 'open-uri'
  require 'json'

  # GET /stocks or /stocks.json
  def index
    # fetch the stock for the current user
    @stocks = current_user.stocks

    # fetch the total investment and total value for the current user
    total_investment = 0
    total_value = 0
    @stocks.each do |stock|
      total_investment += stock.investment
      total_value += stock.price * (stock.investment / stock.buy_price)
    end
    # set the instance variables
    @total_investment = total_investment
    @total_value = total_value

    # chart data
    @chart_data_total = {
      "Total_Cost" => total_investment,
      "Current_Value" => total_value,
    }

    @chart_data_each_stock = {}
    total_investment = 0

    @stocks.each do |stock|
      total_investment += stock.investment
    end

    @stocks.each do |stock|
      percentage = total_investment.zero? ? 0 : (stock.investment / total_investment) * 100
      formatted_percentage = ActionController::Base.helpers.number_to_percentage(percentage, precision: 0)
      @chart_data_each_stock[stock.ticker] = formatted_percentage
    end




  end

  # GET /stocks/1 or /stocks/1.json
  def show
    @stock = Stock.find(params[:id])
    ticker = @stock.ticker
    limit = 365 # max 5000, default 10
    timespan = "day" # day, week, month, quarter, year
    window = 50 # could be 10, 20, 50, 100, 200 ema
    api_key = ENV['POLYGON_API_KEY']

    url = "https://api.polygon.io/v1/indicators/ema/#{ticker}?timespan=#{timespan}&adjusted=true&window=#{window}&series_type=close&order=desc&limit=#{limit}&apiKey=#{api_key}"
    response = URI.open(url).read
    data = JSON.parse(response)
    values = data["results"]["values"]

    @timestamp = values.map do |value|
      Time.at(value["timestamp"]/1000).strftime("%Y-%m-%d")
    end

    @value = values.map do |value|
      value["value"].round(2)
    end

  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks or /stocks.json
  def create
    @stock = Stock.new(stock_params)
    @stock.user_id = current_user.id

    respond_to do |format|
      if @stock.save
        # Fetch the latest stock quote after saving the stock record
        @stock_info = PolygonService.fetch_quote(@stock.ticker)


        # Check if the stock quote was fetched successfully
        if @stock_info[:price].present?
          # Convert the API date
          date_seconds= @stock_info[:date]/1000
          api_date = DateTime.strptime(date_seconds.to_s, '%s')
          share = @stock.investment / @stock.buy_price
          value = @stock_info[:price] * share
          profit = value - @stock.investment
          # Update the stock record with the fetched price
          @stock.update(price: @stock_info[:price], updated_at: api_date, share: share, value: value, profit: profit)
          format.html { redirect_to stock_url(@stock), notice: "Stock was successfully created." }
          format.json { render :show, status: :created, location: @stock }
        else
          # Handle the case where the stock quote could not be fetched
          @stock.destroy
          format.html { render :new, status: :unprocessable_entity, alert: "Failed to fetch stock quote." }
          format.json { render json: { error: "Failed to fetch stock quote." }, status: :unprocessable_entity }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @stock.update(stock_params)
        # Fetch the latest stock quote after updating the stock record
        @stock_info = PolygonService.fetch_quote(@stock.ticker)

        # Check if the stock quote was fetched successfully
        if @stock_info[:price].present?
          # Convert the API date
          date_seconds= @stock_info[:date]/1000
          api_date = DateTime.strptime(date_seconds.to_s, '%s')
          share = @stock.investment / @stock.buy_price
          value = @stock_info[:price] * share
          profit = value - @stock.investment
          # Update the stock record
          @stock.update(price: @stock_info[:price], updated_at: api_date, share: share, value: value, profit: profit)
          format.html { redirect_to stock_url(@stock), notice: "Stock was successfully updated." }
          format.json { render :show, status: :ok, location: @stock }
        else
          # Handle the case where the stock quote could not be fetched
          format.html { render :edit, status: :unprocessable_entity, alert: "Failed to fetch updated stock quote." }
          format.json { render json: { error: "Failed to fetch updated stock quote." }, status: :unprocessable_entity }
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end

  end

  def update_price
    # Fetch the latest stock quote after updating the stock record
    @stock = Stock.find(params[:id])
    @stock_info = PolygonService.fetch_quote(@stock.ticker)
  # Check if the stock quote was fetched successfully
    if @stock_info[:price].present?
      # Update the stock and date record with the fetched price
      date_seconds= @stock_info[:date]/1000
      api_date = DateTime.strptime(date_seconds.to_s, '%s')
      @stock.update(price: @stock_info[:price], updated_at: api_date)
      redirect_to stocks_path, notice: 'Stock price was successfully updated.'
    else
      # Handle the case where the stock quote could not be fetched
      redirect_to stocks_path, alert: 'Failed to fetch stock quote for price update.'
    end

  end

  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    @stock = Stock.find(params[:id])
    @stock.destroy
    redirect_to stocks_path
  end

  def correct_user
    @stock = current_user.stocks.find_by(id: params[:id])
    redirect_to stocks_path, notice: "Not authorized to edit this stock" if @stock.nil?
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_params
      params.require(:stock).permit(:ticker, :name, :price, :share, :buy_price, :investment, :updated_at, :value, :user_id)
    end
end
