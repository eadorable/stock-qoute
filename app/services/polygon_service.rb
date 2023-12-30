
# class PolygonService
#   def get_stock_quote(ticker)
#     base_url = 'https://api.polygon.io/v2'
#     api_key = ENV['POLYGON_API_KEY']
#     ticker = ticker.to_s.strip
#     url = "#{base_url}/aggs/ticker/#{ticker}/prev?adjusted=true&apiKey=#{api_key}"

#     begin
#       response = URI.open(url).read
#       parsed_response = JSON.parse(response)
#       return parsed_response
#     rescue OpenURI::HTTPError => e
#       # Handle HTTP errors, e.g., by raising an exception or returning nil
#       puts "HTTP Error: #{e.message}"
#       return nil
#     rescue JSON::ParserError => e
#       # Handle JSON parsing errors, e.g., by raising an exception or returning nil
#       puts "JSON Parsing Error: #{e.message}"
#       return nil
#     end
#   end
# end

class PolygonService
  require 'open-uri'
  require 'json'

  def self.fetch_quote(ticker)
    base_url = 'https://api.polygon.io/v2'
    api_key = ENV['POLYGON_API_KEY']
    ticker = ticker.to_s.strip.upcase

    if ticker.present?
      url = "#{base_url}/aggs/ticker/#{ticker}/prev?adjusted=true&apiKey=#{api_key}"

      begin
        response = URI.open(url).read
        parsed_response = JSON.parse(response)

        if parsed_response["queryCount"].nil?
          return { error: "Invalid symbol entered" }
        else
          return {
            symbol: parsed_response["ticker"],
            price: parsed_response["results"][0]["c"]
          }
        end
      rescue OpenURI::HTTPError => e
        return { error: "HTTP Error: #{e.message}" }
      rescue StandardError => e
        return { error: "An error occurred: #{e.message}" }
      end
    else
      return { empty: "Enter a stock ticker to get a quote" }
    end
  end
end
