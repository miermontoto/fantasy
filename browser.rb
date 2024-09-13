require 'faraday'
require_relative 'token'

class Browser
  attr_accessor :conn
  BASE_URL = 'fantasy.marca.com'

  def initialize
    token = Token.new 'TOKEN'
    refresh = Token.new 'REFRESH'
    @conn = Faraday.new(url: "https://#{BASE_URL}") do |faraday|
      faraday.headers['Host'] = BASE_URL
      faraday.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
      faraday.headers['Cookie'] = "token=#{token.value}; refresh-token=#{refresh.value}"
    end
  end

  def feed
    @conn.get('/feed')
  end

  def market
    @conn.get('/market')
  end

  def team
    @conn.get('/team')
  end

  def standings
    @conn.get('/standings')
  end
end
