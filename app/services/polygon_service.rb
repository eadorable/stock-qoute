require 'open-uri'
require 'json'

class PolygonService
  BASE_URL = 'https://api.polygon.io/v2'
  def initialize(api_key)
    @api_key = api_key
  end

  def get_stock_quote(symbol)
    url = "#{BASE_URL}/aggs/ticker/#{symbol}/prev?adjusted=true&apiKey=#{@api_key}"

    begin
      response = URI.open(url).read
      parsed_response = JSON.parse(response)
      return parsed_response
    rescue OpenURI::HTTPError => e
      # Handle HTTP errors, e.g., by raising an exception or returning nil
      puts "HTTP Error: #{e.message}"
      return nil
    rescue JSON::ParserError => e
      # Handle JSON parsing errors, e.g., by raising an exception or returning nil
      puts "JSON Parsing Error: #{e.message}"
      return nil
    end
  end
end
