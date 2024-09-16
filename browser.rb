require 'faraday'
require_relative 'token'

class Browser
  BASE_URL = 'fantasy.marca.com'
  BASIC_ENDPOINTS = %i[feed market team standings]

  def initialize
    token = Token.new 'TOKEN'
    refresh = Token.new 'REFRESH'
    @conn = Faraday.new(url: "https://#{BASE_URL}") do |faraday|
      faraday.headers['Host'] = BASE_URL
      faraday.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
      faraday.headers['Cookie'] = "token=#{token.value}; refresh-token=#{refresh.value}"
    end
  end

  def method_missing(method_name, *args, &block)
    if BASIC_ENDPOINTS.include?(method_name) then
      @conn.get("/#{method_name}")
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    BASIC_ENDPOINTS.include?(method_name) || super
  end
end
