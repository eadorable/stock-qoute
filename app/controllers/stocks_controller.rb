class StocksController < ApplicationController
  before_action :set_stock, only: %i[ show edit update destroy ]
  before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!


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
      @stocks.each do |stock|
        @chart_data_each_stock[stock.ticker] = stock.value
        
      end


  end

  # GET /stocks/1 or /stocks/1.json
  def show
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
          # Update the stock record with the fetched price
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


  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    # @stock.destroy

    # respond_to do |format|
    #   format.html { redirect_to stocks_url, notice: "Stock was successfully destroyed." }
    #   format.json { head :no_content }
    # end

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
      params.require(:stock).permit(:ticker, :user_id, :name, :price, :share, :buy_price, :investment, :updated_at, :value)
    end
end
