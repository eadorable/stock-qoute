# app/services/stock_quote_service.rb

class StockQuoteService
  require 'uri'
  require 'net/http'
  require 'json'
  require 'open-uri'
  
  def self.fetch_quote(ticker)
    ticker = ticker.to_s.strip

    if ticker.present?
      begin
        url = URI("https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-quotes?region=US&symbols=#{ticker}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["X-RapidAPI-Key"] = ENV['RAPIDAPI_KEY'] # from .env file
        request["X-RapidAPI-Host"] = 'apidojo-yahoo-finance-v1.p.rapidapi.com'

        response = http.request(request)
        response_read = response.read_body

        if response_read.present?
          stock_json = JSON.parse(response_read)
          if stock_json['quoteResponse']['result'].present?
            return {
              symbol: stock_json['quoteResponse']['result'][0]['symbol'],
              name: stock_json['quoteResponse']['result'][0]['shortName'],
              price: stock_json['quoteResponse']['result'][0]['regularMarketPrice']
            }
          else
            return { error: "Invalid symbol entered" }
          end
        else
          return { empty: "Enter a stock ticker to get a quote" }
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET => e
        return { error: "Network error: #{e.message}" }
      end
    else
      return { empty: "Enter a stock ticker to get a quote" }
    end
  end
end
