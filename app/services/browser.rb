require "faraday"
require_relative "token"

class Browser
  BASE_URL = "fantasy.marca.com"
  BASIC_ENDPOINTS = %i[feed market team standings]

  def initialize
    setup_connection
    get_current_community_id
  end

  def self.current_community_id
    Token.get_current_community
  end

  def get_current_community_id
    return Token.get_current_community unless Token.get_current_community.nil?

    scraper = Scraper.new(false)
    tokens = Token.list_tokens.keys
    if tokens.empty? then; puts "error: no se han encontrado tokens".red; return; end
    tokens.each do |token|
      setup_connection(token.to_i)
      feed = scraper.feed(self.feed.body)
      community_name = feed[:info][:community]
      id = find_community_by_name(community_name, false)
      Token.set_current_community(id) if id
      return if id
    end

    Token.set_current_community(nil)
    puts "error: no se ha encontrado ninguna comunidad".red
  end

  def setup_connection(community_id = nil)
    xauth = Token.get_xauth(community_id || Token.get_current_community) || nil

    @conn = Faraday.new(url: "https://#{BASE_URL}") do |faraday|
      faraday.headers["Host"] = BASE_URL
      faraday.headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
      faraday.headers["Cookie"] = "refresh-token=#{Token.refresh_token}"
      faraday.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
      faraday.headers["X-Requested-With"] = "XMLHttpRequest"
      faraday.headers["X-Auth"] = xauth if xauth
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

  def player(id)
    if id.nil? then; puts "error: id no proporcionado".red; return; end
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
      response = @conn.get("/action/change?id_community=#{id}")
      Token.set_current_community(id)
      setup_connection(id) if response.status == 200
      return
    end

    true_id = find_community_by_name(id)
    if true_id.nil? then
      puts "error: no se ha encontrado ninguna comunidad con ese nombre".red
      return
    end

    self.change_community(true_id)
  end

  def find_community_by_name(name, print = true)
    scraper = Scraper.new(false)
    list = scraper.communities(self.communities.body)[:communities]
    if list.nil? then
      puts "error: no se ha podido obtener la lista de comunidades".red if print
      return
    end

    list.each do |community|
      if community.name.downcase.include?(name.downcase) then
        return community.id.to_i
      end
    end

    nil
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
