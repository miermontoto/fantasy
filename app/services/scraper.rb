require "nokogiri"
require "colorize"

class Scraper
  include FantasyHelper

  def initialize
    @browser = Browser.new
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
      Player.new({
        name: player.css(".name").text.strip,
        # team: player.css('.team-logo')['src'],
        position: player.css(".icons i").attr("class").value,
        points: player.css(".points").text.strip,
        value: player.css(".underName").text.gsub(/[^0-9]/, ""),
        average: player.css(".avg").text.strip,
        streak: player.css(".streak span").map { |span| span.text.strip }
      })
    end

    # transferencias recientes
    recent_transfers = doc.css(".card-transfer").map do |block|
      date = block.css(".date").text.strip
      block.css(".player-list>li").map do |transfer|
        Transfer.new({
          player: transfer.css(".title strong").text.strip,
          position: transfer.css(".player-row .icons i").attr("class").value,
          from: transfer.css(".title em").first.text.strip,
          to: transfer.css(".title em").last.text.strip,
          price: transfer.css(".price").first.text.strip,
          date: date,
          status: transfer.css(".status use")&.attr("href")&.value&.split("#")&.last,
          user: user_name,
          player_img: transfer.css(".player-pic.qd-player img").attr("src").value
        })
      end
    end

    puts "información general".grey.bold
    puts "#{"liga:".bold} #{community_name}"
    puts "#{"balance:".bold} #{user_balance}"
    puts "#{"créditos:".bold} #{user_credits}"
    puts "#{"jornada:".bold} #{gameweek} (#{gameweek_status})"

    puts "\ntop jugadores en el mercado".grey.bold
    market_players.each { |player| puts player }

    puts "\ntransferencias recientes".grey.bold
    recent_transfers.flatten.each { |transfer| puts transfer }
  end

  def market(html)
    doc = Nokogiri::HTML(html)

    players = doc.css("#list-on-sale li").map do |player|
      Player.new({
        id: player.css(".player-pic.qd-player").attr("data-id_player").value,
        name: player.css(".name").text.strip,
        seller: player.css(".date").text.strip,
        position: player.css(".icons i").attr("class").value,
        points: player.css(".points").text.strip.to_i,
        value: player.css(".underName").text.gsub(/[^0-9]/, "").to_i,
        trend: player.css(".value-arrow").text.strip,
        average: player.css(".avg").text.strip,
        streak: player.css(".streak span").map { |span| span.text.strip },
        status: player.css(".status use")&.attr("href")&.value&.split("#")&.last,
        sale: player.css(".player-btns .btn-bid").text.gsub(/[^0-9]/, "").to_i,
        player_img: player.css(".player-pic.qd-player img").attr("src").value
      })
    end

    players = sort_players(players)

    footer_info = {
      current_balance: format_num(doc.css(".footer-sticky-market .balance-real-current").text.gsub(/\./, "").to_i),
      future_balance: format_num(doc.css(".balance-real-future").text.gsub(/\./, "").to_i),
      max_debt: format_num(doc.css(".balance-real-maxdebt").text.gsub(/\./, "").to_i)
    }
    next_update = doc.css(".next-update").text.split("en").last.strip

    puts "información general".grey.bold
    puts "#{"balance:".bold} #{footer_info[:current_balance]}€"
    puts "#{"balance futuro:".bold} #{footer_info[:future_balance]}€"
    puts "#{"deuda máx.:".bold} #{footer_info[:max_debt]}€"
    puts "#{"next update".bold} #{next_update}"

    puts "\nmercado".grey.bold
    players.each { |player| puts player }
  end

  def team(html)
  end

  def standings(html)
    doc = Nokogiri::HTML(html)

    total = doc.css(".panel-total li").map do |user|
      User.new({
        position: user.css(".position").text.strip,
        name: user.css(".name").text.strip,
        players: user.css(".played").text.split("·").first.strip.split(" ").first.to_i,
        value: user.css(".played").text.split("·").last.strip.gsub(/[^0-9]/, "").to_i,
        points: user.css(".points:not(span)").text.split(" ").first.strip.to_i,
        diff: user.css(".diff").text.strip
      })
    end

    gameweek = doc.css(".panel-gameweek li").map do |user|
      User.new({
        position: user.css(".position").text.strip,
        name: user.css(".name").text.strip,
        players: user.css(".played").text.split("·").first.strip.split(" ").first.to_i,
        value: user.css(".played").text.split("·").last.strip.gsub(/[^0-9]/, "").to_i,
        points: user.css(".points:not(span)").text.split(" ").first.strip.to_i
      })
    end

    jornada = doc.css(".top select option[selected]").text.strip

    puts "clasificación general".grey.bold
    total.each { |user| puts user }

    puts "\nclasificación #{jornada.downcase}".grey.bold
    gameweek.each { |user| puts user }
  end

  def team(html)
    doc = Nokogiri::HTML(html)

    squad_players = doc.css(".player-list.list-team li").map do |player|
      Player.new({
        name: player.css(".name").text.strip.gsub(/\s+/, " "),
        position: player.css(".icons i").attr("class").value,
        points: player.css(".points").text.strip,
        value: player.css(".underName").text.gsub(/[^\d]/, "").to_i,
        average: player.css(".avg").text.strip,
        streak: player.css(".streak span").map { |span| span.text.strip },
        trend: player.css(".value-arrow").text.strip,
        player_img: player.css(".player-pic.qd-player img").attr("src").value
      })
    end

    puts "plantilla".grey.bold
    squad_players.each { |player| puts player }
  end

  def offers(html)
    puts html
  end
end
