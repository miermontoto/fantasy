require 'faraday'
require_relative '../token'

class Browser
  BASE_URL = 'fantasy.marca.com'
  BASIC_ENDPOINTS = %i[feed market team standings]

  def initialize
    # xauth = Token.new 'XAUTH'
    refresh = Token.new 'REFRESH'

    @conn = Faraday.new(url: "https://#{BASE_URL}") do |faraday|
      faraday.headers['Host'] = BASE_URL
      faraday.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
      faraday.headers['Cookie'] = "refresh-token=#{refresh.value}"
      faraday.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
      faraday.headers['X-Requested-With'] = 'XMLHttpRequest'
      # faraday.headers['X-Auth'] = xauth.value
    end
  end

  def method_missing(method_name, *args, &block)
    if BASIC_ENDPOINTS.include?(method_name) then
      fetch("/#{method_name}")
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    BASIC_ENDPOINTS.include?(method_name) || super
  end

  def players(id)
    @conn.post("/ajax/sw") do |req|
      req.body = "post=players&id=#{id}"
    end
  end

  def teams(id)
    @conn.post("/ajax/sw") do |req|
      req.body = "post=teams&id=#{id}"
    end
  end

  def players
    @conn.post("/ajax/sw") do |req|
      req.body = "post=players&order=0"
    end
  end

  def fetch(path)
    Helpers.display_debug("→ /#{path}")
    response = @conn.get(path)
    Helpers.display_debug("← #{response.status}")

    if response.status == 200
      response.body
    else
      raise "HTTP Error: #{response.status}"
    end
  rescue Faraday::Error => e
    Helpers.display_debug("x #{e.message}")
    raise "Network Error: #{e.message}"
  end
end
