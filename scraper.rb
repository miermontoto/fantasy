require 'nokogiri'
require 'colorize'

require_relative 'helpers'

$POSITIONS = {
  'pos-1' => '[PT]'.yellow,
  'pos-2' => '[DF]'.cyan,
  'pos-3' => '[MC]'.green,
  'pos-4' => '[DL]'.red
}
$MARKET_NAME = 'Fantasy MARCA'

class Scraper
  def feed(html)
    doc = Nokogiri::HTML(html)

    # general info
    community_name = doc.css('.feed-top-community .name span').text.strip
    user_name = doc.css('.header .name').text.strip
    user_balance = doc.css('.balance-real-current').text.strip
    user_credits = doc.css('.credits-count').first.text.strip

    # jornada
    gameweek = doc.css('.gameweek__name').text.strip
    gameweek_status = doc.css('.gameweek__status').text.strip.gsub(/\s+/, ' ')

    # top market players
    market_players = doc.css('.card-market_unified .player-list li').map do |player|
      {
        name: player.css('.name').text.strip,
        # team: player.css('.team-logo')['src'],
        position: $POSITIONS[player.css('.icons i').attr('class').value],
        points: player.css('.points').text.strip,
        value: player.css('.player-btns .btn-bid').text.strip
      }
    end

    # transferencias recientes
    recent_transfers = doc.css('.card-transfer').map do |transfer|
      {
        player: transfer.css('strong').first.text.strip,
        position: $POSITIONS[transfer.css('.icons i').attr('class').value],
        from: transfer.css('.title em').first.text.strip,
        to: transfer.css('.title em').last.text.strip,
        price: format_num(transfer.css('.price').first.text.strip) + '€'
      }
    end

    puts "información general".grey.bold
    puts "#{"liga:".bold} #{community_name}"
    puts "#{"balance:".bold} #{user_balance}"
    puts "#{"créditos:".bold} #{user_credits}"
    puts "#{"jornada:".bold} #{gameweek} (#{gameweek_status})"

    puts "\ntop jugadores en el mercado".grey.bold
    market_players.each do |player|
      puts "#{player[:position]} #{"(#{player[:points]}pts)".ljust(8)} #{player[:name].ljust(15)} - #{player[:value]}€"
    end

    puts "\ntransferencias recientes".grey.bold
    recent_transfers.each do |transfer|
      target = "(#{transfer[:from]} → #{transfer[:to]})"
      if transfer[:from] == $MARKET_NAME then
        target = "(#{"+".green} #{transfer[:to]})"
      elsif transfer[:to] == $MARKET_NAME then
        target = "(#{"-".red} #{transfer[:from]})"
      end
      string = "#{transfer[:position]} #{transfer[:player].ljust(18)} #{transfer[:price].ljust(12)} #{target}"

      if transfer[:from] == user_name or transfer[:to] == user_name then
        puts string.bold
      else
        puts string
      end
    end
  end

  def market(html)
    doc = Nokogiri::HTML(html)

    players = doc.css('#list-on-sale li').map do |player|
      {
        id: player['class'].split('-').last,
        name: player.css('.name').text.strip,
        # team: player.css('.team-logo')['src'],
        seller: player.css('.date').text.strip,
        position: $POSITIONS[player.css('.icons i').attr('class').value],
        points: player.css('.points').text.strip.to_i,
        value: format_num(player.css('.underName').text.gsub(/[^0-9]/, '').to_i),
        trend: player.css('.value-arrow').text.strip,
        avg_points: player.css('.avg').text.strip.to_f,
        streak: player.css('.streak span').map { |span| span.text.strip },
        # next_rival: player.css('.rival img')['src'],
        status: player.css('.status use')&.attr('href')&.value&.split('#')&.last,
        sale_price: format_num(player.css('.player-btns .btn-bid').text.gsub(/[^0-9]/, '').to_i)
      }
    end

    footer_info = {
      current_balance: format_num(doc.css('.footer-sticky-market .balance-real-current').text.gsub(/\./, '').to_i),
      future_balance: format_num(doc.css('.balance-real-future').text.gsub(/\./, '').to_i),
      max_debt: format_num(doc.css('.balance-real-maxdebt').text.gsub(/\./, '').to_i)
    }
    next_update = doc.css('.next-update').text.split('en').last.strip

    puts "información general".grey.bold
    puts "#{"balance:".bold} #{footer_info[:current_balance]}€"
    puts "#{"balance futuro:".bold} #{footer_info[:future_balance]}€"
    puts "#{"deuda máx.:".bold} #{footer_info[:max_debt]}€"
    puts "#{"next update".bold} #{next_update}"

    puts "\nmercado".grey.bold
    players.each do |player|
      status = player[:status] ? " [#{player[:status].upcase}] " : ""
      name = "#{player[:name]}#{status}"
      trend = player[:trend] == '↑' ? player[:trend].green : player[:trend].red
      price = "#{player[:value]}€#{" (#{player[:sale_price]}€)" unless player[:sale_price] == player[:value]}"
      points = "#{player[:points]} (#{player[:avg_points].round(2)})"

      string = "#{player[:position]} #{name.ljust(25)} - #{points.ljust(8)} - #{trend} #{price.ljust(24)}"
      if status != "" then
        puts string.italic
      else
        puts string
      end
    end
  end

  def team(html)

  end

  def standings(html)

  end
end
