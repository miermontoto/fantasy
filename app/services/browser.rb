require "faraday"
require_relative "token"

class Browser
  BASE_URL = "fantasy.marca.com"
  BASIC_ENDPOINTS = %i[feed market team standings]

  def initialize
    xauth = Token.new("XAUTH", false)
    refresh = Token.new("REFRESH")

    if xauth.value.nil? then; puts "WARNING: XAUTH token not found"; end

    @conn = Faraday.new(url: "https://#{BASE_URL}") do |faraday|
      faraday.headers["Host"] = BASE_URL
      faraday.headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
      faraday.headers["Cookie"] = "refresh-token=#{refresh.value}"
      faraday.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
      faraday.headers["X-Requested-With"] = "XMLHttpRequest"
      faraday.headers["X-Auth"] = xauth.value unless xauth.nil?
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

  def feed_events
    @conn.post("/ajax/feed") do |req|
      req.body = "end=false&loading=true&offset=20"
    end
  end

  def offers
    @conn.post("/ajax/sw/offers-received") do |req|
      req.body = "post=offers-received"
    end
  end
end
