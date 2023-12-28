class HomeController < ApplicationController
  require 'uri'
  require 'net/http'
  require 'json'
  require 'open-uri'

  def about
  end

  def index
    @stock_info = fetch_stock_quote(params[:ticker]) # call fetch_stock_quote method
    if @stock_info.nil?
      @error = "Check your internet connection"
    end

    # error handling
    if params[:ticker].nil? # if no symbol entered
      @empty = "No symbol entered"
    elsif @stock_info == "{\"quoteResponse\":{\"result\":[],\"error\":null}}" || @stock_info.nil?  # if symbol entered is invalid
      @error = "Invalid symbol"
    else
      @stock_json = JSON.parse(@stock_info)
      @stock_symbol = @stock_json['quoteResponse']['result'][0]['symbol']
      @stock_name = @stock_json['quoteResponse']['result'][0]['shortName']
      @stock_price = @stock_json['quoteResponse']['result'][0]['regularMarketPrice']
    end
  end
end

private

def fetch_stock_quote(ticker)

  url = URI("https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-quotes?region=US&symbols=#{ticker}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  # need to setup error handling for when the API or internet is down
  request = Net::HTTP::Get.new(url)
  request["X-RapidAPI-Key"] = ENV['RAPIDAPI_KEY'] # from .env file
  request["X-RapidAPI-Host"] = 'apidojo-yahoo-finance-v1.p.rapidapi.com'

  response = http.request(request)
  response_read = response.read_body
end
