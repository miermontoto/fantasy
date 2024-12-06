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

  # todas las llamadas AJAX requieren el token XAUTH

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

  def communities
    @conn.post("/ajax/community-check")
  end

  def change_community(id)
    puts "cambiando a comunidad #{id}"

    # si es un número, se cambia a esa comunidad
    if id.is_a?(Integer) || id.to_i.to_s == id then
      @conn.get("/action/change?id_community=#{id}")
      return
    end

    # si es una cadena, hacer un LIKE y cambiar al primer resultado
    list = Scraper.new.communities(self.communities.body)[:communities]
    if list.nil? then; puts "error: no se ha podido obtener la lista de comunidades".red; return; end
    list.each do |community|
      if community.name.downcase.include?(id.downcase) then
        puts "cambiando a comunidad #{community.name}"
        self.change_community(community.id.to_i)
        return
      end
    end

    puts "error: no se ha encontrado ninguna comunidad con ese nombre".red
  end

  def top_market(interval = "day")
    valid_intervals = %w[day week month]
    if !valid_intervals.include?(interval) then; puts "error: intervalo inválido".red; return; end

    @conn.post("/ajax/sw/market") do |req|
      req.body = "post=market&interval=#{interval}"
    end
  end

  def top_players
    @conn.post("/ajax/sw/players") do |req|
      filters = {
        position: 0,
        value: 0,
        team: 0,
        injured: 0,
        favs: 0,
        owner: 0,
        benched: 0,
        stealable: 0
      }
      req.body = "post=players&filters=#{filters.to_json}"
    end
  end
end
