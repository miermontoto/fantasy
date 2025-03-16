require "nokogiri"
require "colorize"
require "json"

class Scraper
  include ApplicationHelper

  def initialize(print = true)
    @print = print
  end

  def feed(html)
    doc = Nokogiri::HTML(html)

    # general info
    community_name = doc.css(".feed-top-community .name span").text.strip
    user_name = doc.css(".header .name").text.strip
    user_balance = doc.css(".balance-real-current").text.strip
    user_credits = doc.css(".credits-count").first.text.strip

    # jornada
    gameweek = doc.css(".gameweek__name").text.strip
    gameweek_status = doc.css(".gameweek__status").text.strip.gsub(/\s+/, " ")

    # top market players
    market_players = doc.css(".card-market_unified .player-list li").map do |player|
      MarketPlayer.new({
        name: player.css(".name").text.strip,
        team_img: player.css("img.team-logo").attr("src").value,
        position: player.css(".icons i").attr("class").value,
        points: player.css(".points").text.strip,
        value: player.css(".underName").text.gsub(/[^0-9]/, "").to_i,
        average: player.css(".avg").text.strip,
        streak: player.css(".streak span").map { |span| span.text.strip },
        player_img: player.css(".player-pic.qd-player img").attr("src").value,
        owner: ApplicationHelper::FREE_AGENT,
        rival_img: player.css(".rival img").attr("src").value
      })
    end

    # transferencias recientes
    recent_transfers = doc.css(".card-transfer").map do |block|
      date = block.css(".head>.date").first.text.strip.gsub("hace ", "")

      block.css(".player-list>li").map do |transfer|
        TransferPlayer.new({
          name: transfer.css(".title strong").first.text.strip,
          position: transfer.css(".player-row .icons i").attr("class").value,
          team_img: transfer.css("img.team-logo").attr("src").value,
          from: transfer.css(".title em").first.text.strip,
          to: transfer.css(".title em")[1].text.strip,
          value: transfer.css(".price").first.text.strip,
          date: date,
          status: transfer.css(".status use")&.attr("href")&.value&.split("#")&.last,
          player_img: transfer.css(".player-pic.qd-player img").attr("src").value,
          clause: transfer.css(".title").text.include?("por pago de cláusula"),
          other_bids: transfer.css("ul.other-bids li:not(.other-bids-title)").map {
            |bid| [bid.css("strong").text.strip, bid.text.strip.split("›").last.strip]
          }
        })
      end
    end

    recent_transfers.flatten!

    # gameweek start events
    gameweek_starts = doc.css(".card-gameweek_start").map do |block|
      {
        type: :gameweek_start,
        gameweek: block.css(".title").text.strip,
        subtitle: block.css(".subtitle").text.strip,
        date: block.css(".date").text.strip
      }
    end

    # gameweek end events
    gameweek_ends = doc.css(".card-gameweek_end").map do |block|
      users = block.css(".user-list li").map do |user|
        {
          position: user.css(".position").text.strip,
          name: user.css(".name").text.strip,
          points: user.css(".points .value").text.strip.to_i,
          profit: user.css(".info .green").text.strip,
          user_img: user.css(".pic img").attr("src")&.value
        }
      end

      {
        type: :gameweek_end,
        gameweek: block.css(".head .title strong").text.strip,
        date: block.css(".head .date").text.strip,
        rankings: users
      }
    end

    # clause drops events
    clause_drops = doc.css(".card-clauses_drops").map do |block|
      players = block.css(".player-list li").map do |player|
        {
          name: player.css(".title strong").text.strip,
          owner: player.css(".title em").text.strip,
          team_img: player.css(".team-logo").attr("src").value,
          position: player.css(".icons i").attr("class").value,
          points: player.css(".points").text.strip.to_i,
          old_price: player.css(".flow .price").last.text.strip,
          new_price: player.css(".flow .price.red").text.strip,
          player_img: player.css(".player-pic.qd-player img").attr("src").value
        }
      end

      {
        type: :clause_drops,
        date: block.css(".head .date").text.strip,
        players: players
      }
    end

    # Combine all events into a single array with timestamps
    all_events = []

    # Add gameweek starts
    gameweek_starts.each do |event|
      all_events << Event.new({
        type: :gameweek_start,
        date: parse_date(event[:date]),
        raw_date: event[:date],
        data: event
      })
    end

    # Add gameweek ends
    gameweek_ends.each do |event|
      all_events << Event.new({
        type: :gameweek_end,
        date: parse_date(event[:date]),
        raw_date: event[:date],
        data: event
      })
    end

    # Add clause drops
    clause_drops.each do |event|
      all_events << Event.new({
        type: :clause_drops,
        date: parse_date(event[:date]),
        raw_date: event[:date],
        data: event
      })
    end

    # Add transfers
    recent_transfers.each do |transfer|
      all_events << Event.new({
        type: :transfer,
        date: parse_date(transfer.date),
        raw_date: transfer.date,
        data: transfer
      })
    end

    # Sort all events by date
    all_events.sort_by! { |event| event.date }.reverse!

    if @print then
      puts "información general".grey.bold
      puts "#{"liga:".bold} #{community_name}"
      puts "#{"balance:".bold} #{user_balance}"
      puts "#{"créditos:".bold} #{user_credits}"
      puts "#{"jornada:".bold} #{gameweek} (#{gameweek_status})"

      puts "\ntop jugadores en el mercado".grey.bold
      market_players.each { |player| puts player }

      puts "\neventos".grey.bold
      all_events.each { |event| puts event }
    end

    {
      events: all_events,
      market: market_players,
      info: {
        community: community_name,
        balance: user_balance,
        credits: user_credits,
        gameweek: gameweek,
        status: gameweek_status
      }
    }
  end

  def market(html)
    doc = Nokogiri::HTML(html)

    players = doc.css("#list-on-sale li").map do |player|
      MarketPlayer.new({
        id: player.css(".player-pic.qd-player").attr("data-id_player").value,
        name: player.css(".name").text.strip,
        team_img: player.css("img.team-logo").attr("src").value,
        offered_by: player.css(".date").text.strip.split(",").first,
        position: player.css(".icons i").attr("class").value,
        points: player.css(".points").text.strip.to_i,
        value: player.css(".underName").text.gsub(/[^0-9]/, "").to_i,
        trend: player.css(".value-arrow").text.strip,
        average: player.css(".avg").text.strip,
        streak: player.css(".streak span").map { |span| span.text.strip },
        status: player.css(".status use")&.attr("href")&.value&.split("#")&.last,
        player_img: player.css(".player-pic.qd-player img").attr("src").value,
        asked_price: player.css(".btn.btn-popup.btn-grey").text.strip.gsub(/[^0-9]/, "").to_i,
        my_bid: player.css(".btn.btn-popup.btn-green.btn-bid").text.strip.gsub(/[^0-9]/, "").to_i,
        rival_img: player.css(".rival img")&.attr("src")&.value,
        own: player.css(".btn.btn-popup").text.strip.include?(ApplicationHelper::SELLING_TEXT)
      })
    end

    players = sort_players(players)

    footer_info = {
      current_balance: format_value(doc.css(".footer-sticky-market .balance-real-current").text.gsub(/\./, "").to_i),
      future_balance: format_value(doc.css(".balance-real-future").text.gsub(/\./, "").to_i),
      max_debt: format_value(doc.css(".balance-real-maxdebt").text.gsub(/\./, "").to_i),
      # next_update: doc.css(".next-update").text.split("en").last.strip
    }

    if @print then
      puts "información general".grey.bold
      puts "#{"balance:".bold} #{footer_info[:current_balance]}€"
      puts "#{"balance futuro:".bold} #{footer_info[:future_balance]}€"
      puts "#{"deuda máx.:".bold} #{footer_info[:max_debt]}€"
      puts "#{"next update".bold} #{footer_info[:next_update]}"

      puts "\nmercado".grey.bold
      players.each { |player| puts player unless player.own }
    end

    { market: players, info: footer_info }
  end

  def standings(html)
    doc = Nokogiri::HTML(html)

    total = doc.css(".panel-total li").map do |user|
      User.new({
        id: user.css(".user").attr("href")&.value&.match(/users\/(\d+)/)&.[](1),
        position: user.css(".position").text.strip,
        name: user.css(".name").text.strip,
        players: user.css(".played").text.split("·").first.strip.split(" ").first.to_i,
        value: user.css(".played").text.split("·").last.strip.gsub(/[^0-9]/, "").to_i,
        points: user.css(".points:not(span)").text.split(" ").first.strip.gsub(".", "").to_i,
        diff: user.css(".diff").text.strip,
        user_img: user.css("img").attr("src") ? user.css("img").attr("src").value : nil,
        myself: user.css(".name").to_html.include?("myself")
      })
    end

    gameweek = doc.css(".panel-gameweek li").map do |user|
      User.new({
        id: user.css(".user").attr("href")&.value&.match(/users\/(\d+)/)&.[](1),
        position: user.css(".position").text.strip,
        name: user.css(".name").text.strip,
        players: user.css(".played").text.split("·").first.strip.split(" ").first.to_i,
        # value: user.css(".played").text.split("·").last.strip.gsub(/[^0-9]/, "").to_i,
        points: user.css(".points:not(span)").text.split(" ").first.strip.to_i,
        user_img: user.css("img").attr("src") ? user.css("img").attr("src").value : nil,
        played: user.css(".played").text.strip,
        myself: user.css(".name").to_html.include?("myself")
      })
    end

    jornada = doc.css(".top select option[selected]").text.strip

    if @print then
      puts "clasificación general".grey.bold
      total.each { |user| puts user }

      puts "\nclasificación #{jornada.downcase}".grey.bold
      gameweek.each { |user| puts user }
    end

    { total: total, gameweek: gameweek }
  end

  def team(html)
    doc = Nokogiri::HTML(html)

    squad_players = doc.css(".player-list.list-team li").map do |player|
      TeamPlayer.new({
        id: player.css(".player-pic.qd-player").attr("data-id_player").value,
        name: player.css(".name").text.strip.gsub(/\s+/, " ").strip,
        position: player.css(".icons i").attr("class").value,
        points: player.css(".points").text.strip,
        value: player.css(".underName").text.gsub(/[^\d]/, "").to_i,
        average: player.css(".avg").text.strip,
        streak: player.css(".streak span").map { |span| span.text.strip },
        trend: player.css(".value-arrow").text.strip,
        player_img: player.css(".player-pic.qd-player img").attr("src").value,
        team_img: player.css("img.team-logo").attr("src").value,
        selected: player.attribute_nodes.include?("in-lineup"),
        being_sold: player.css(".btn.btn-popup").text.strip == ApplicationHelper::SELLING_TEXT,
        rival_img: player.css(".rival img").attr("src").value,
        status: player.css(".status use")&.attr("href")&.value&.split("#")&.last
      })
    end

    footer_info = {
      current_balance: format_value(doc.css(".footer-sticky .balance-real-current").text.strip),
      future_balance: format_value(doc.css(".balance-real-future").text.strip),
      max_debt: format_value(doc.css(".balance-real-maxdebt").text.strip)
    }

    if @print then
      puts "plantilla".grey.bold
      squad_players.each { |player| puts player }
    end

    { players: squad_players, info: footer_info }
  end

  def offers(response)
    content = check_ajax_response(response)

    if content.empty? then; return {}; end

    offers = content["offers"]

    puts "ofertas".grey.bold if @print

    if offers.nil? then
      puts "no hay ofertas pendientes" if @print
      return {}
    end

    offers = offers.map do |id, offer|
      OfferPlayer.new({
        id: id,
        name: offer["name"],
        position: "pos-#{offer["position"]}",
        average: offer["avg"],
        value: offer["value"],
        streak: offer["streak"].map { |s| s["points"] },
        date: offer["date"],
        best_bid: offer["bid"],
        offered_by: offer["uname"],
        team_img: offer["teamLogoUrl"],
        player_img: offer["photoUrl"],
        points: offer["points"]
      })
    end

    offers.each { |offer| puts offer } if @print

    { offers: offers }
  end

  def communities(response)
    content = check_ajax_response(response)

    if content.empty? then; return {}; end
    communities = content["communities"].to_h.map do |id, community|
      Community.new({
        id: community["id"],
        name: community["name"],
        icon: community["community_icon"],
        balance: community["balance"],
        offers: community["offers"],
        current: community["id"] == Browser.current_community_id
      })
    end

    if @print then
      puts "comunidades".grey.bold
      communities.each { |community| puts community }
    end

    { communities: communities }
  end

  def top_market(html, timespan = "D")
    content = check_ajax_response(html)

    if content.empty? then; return {}; end

    content = content.to_h

    last = content["last"]
    prev = content["prev"]
    diff = last["value"] - prev["value"]

    positive = content["players"]["positive"].map.with_index(1) do |player, index|
      Player.new({
        position: "pos-#{player["position"]}",
        id: player["id"],
        name: player["name"],
        diff: player["diff"],
        value: player["value"],
        team_img: player["teamLogoUrl"],
        player_img: player["photoUrl"],
        own: player["is_mine"] == 1,
        user: player["uc_name"],
        market_ranks: { timespan => index }
      })
    end

    negative = content["players"]["negative"].reverse.map.with_index(1) do |player, index|
      Player.new({
        position: "pos-#{player["position"]}",
        id: player["id"],
        name: player["name"],
        diff: player["diff"],
        value: player["value"],
        team_img: player["teamLogoUrl"],
        player_img: player["photoUrl"],
        own: player["is_mine"] == 1,
        user: player["uc_name"],
        market_ranks: { timespan => -index }
      })
    end

    if @print then
      puts "últimos valores de mercado".grey.bold
      puts "cambio: #{format_num(last["value"])}€ (#{last["date"]})"
      puts
      puts "positivos".green.bold
      positive.each { |player| puts player }
    end

    { positive: positive, negative: negative, last: last, diff: diff }
  end

  def top_players(html)
    content = check_ajax_response(html)

    if content.empty? then; return {}; end

    players = content.to_h["players"].map do |player|
      Player.new({
        position: "pos-#{player["position"]}",
        id: player["id"],
        name: player["name"],
        value: player["value"],
        average: player["avg"],
        streak: player["streak"],
        points: player["points"],
        status: player["status"],
        previous_value: player["prev_value"],
        clause: player["clause"],
        player_img: player["photoUrl"],
        own: player["is_mine"] == 1,
        user: player["uc_name"]
      })
    end

    if @print then
      puts "top jugadores".grey.bold
      players.each { |player| puts player }
    end

    { players: players, teams: content.to_h["teams"] }
  end

  def player(json, player = nil)
    content = check_ajax_response(json)
    if content.empty? then; return {}; end
    content = content.to_h

    content = {
      values: content["values"].to_a,
      owners: content["owners"].to_a,
      goals: content["player_extra"]["goals"],
      matches: content["player_extra"]["matches"],
      clauses_rank: content["player"]["clausesRanking"],
      clause: content["player"]["clause"]
    }

    player.load_additional_attributes(content) unless player.nil?
    puts content if @print
    player
  end

  def user(json)
    content = check_ajax_response(json)
    if content.empty? then; return {}; end

    content = content.to_h
    players = content["team_now"].map do |player|
      TeamPlayer.new({
        id: player["id"],
        name: player["name"],
        value: player["value"],
        average: player["avg"],
        clause: player["clause"],
        streak: player["streak"].map { |s| s["points"] },
        player_img: player["photoUrl"],
        team_img: player["teamLogoUrl"],
        status: player["status"],
        points: player["points"],
        position: "pos-#{player["position"]}",
        trend: player["prev_value"] > player["value"] ? "↓" : "↑"
      })
    end

    user = User.new({
      bench: players,
      name: content["userInfo"]["name"].strip,
      user_img: content["userInfo"]["avatar"]["pic"],
      points: content["season"]["points"],
      value: content["value"],
      average: content["season"]["avg"]
    })

    puts user if @print
    user
  end

  def teams(html)
    content = check_ajax_response(html)
    if content.empty? then; return {}; end
    content.to_h
  end

  def top_claused(browser)
    # para sacar los jugadores más clausulados, no hay una petición específica,
    # sino que hay que sacar todos los jugadores y ordenarlos según si tienen
    # o no el clause_rank.

    # 1. sacar todos los equipos
    @print = false
    teams = self.top_players(browser.top_players.body)[:teams]

    # 2. por cada equipo, sacar los jugadores
    team_ids = teams.map { |team| team["id"] }
    players = []

    # limitar el número de threads para evitar overhead
    max_threads = [team_ids.size, 10].min
    team_chunks = team_ids.each_slice((team_ids.size.to_f / max_threads).ceil).to_a

    threads = []
    mutex = Mutex.new

    team_chunks.each do |chunk|
      threads << Thread.new do
        chunk_players = []

        chunk.each do |id|
          team_players = self.teams(browser.teams(id).body)["players"]

          # para cada jugador, crear un objeto Player
          team_players.each do |player|
            chunk_players << Player.new({
              id: player["id"],
              name: player["name"],
              value: player["value"],
              average: player["avg"],
              streak: player["streak"],
              points: player["points"],
              status: player["status"]
            })
          end
        end

        mutex.synchronize { players.concat(chunk_players) }
      end
    end

    threads.each(&:join)

    # 3. sobre cada jugador, obtener toda la info adicional (que incluye el clause_rank)
    max_player_threads = 20
    player_batches = players.each_slice((players.size.to_f / max_player_threads).ceil).to_a

    player_batches.each do |batch|
      batch_threads = []

      batch.each do |player|
        batch_threads << Thread.new do
          # el player se rellena dentro del método player
          self.player(browser.player(player.id).body, player)
        end
      end

      batch_threads.each(&:join)
    end

    # 4. filtrar y ordenar los jugadores según el clause_rank
    players_with_clauses = players.select { |player| player.clauses_rank.present? }
    sorted_players = players_with_clauses.sort_by { |player| player.clauses_rank }

    # pretty print results
    puts "top clausulados".grey.bold
    sorted_players.each do |player|
      string_content = [
        "\#" + player.clauses_rank.to_s.ljust(3),
        player.to_s
      ]

      puts concat(string_content)
    end

    sorted_players
  end

  private

  def check_ajax_response(response)
    content = JSON.parse(response)
    status = content["status"]

    if status == "error"
      puts "error al obtener la información (¿XAUTH inválido?)".red.bold if @print
      return {}
    end

    content["data"]
  end

  def parse_date(date_string)
    DateTime.parse(date_string) rescue DateTime.now
  end
end
