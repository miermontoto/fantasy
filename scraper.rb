require 'nokogiri'
require 'colorize'

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
        price: transfer.css('.price').first.text.strip
      }
    end

    puts "información general".grey.bold
    puts "#{"liga:".bold} #{community_name}"
    puts "#{"balance:".bold} #{user_balance}"
    puts "#{"créditos:".bold} #{user_credits}"
    puts "#{"jornada:".bold} #{gameweek} (#{gameweek_status})"

    puts "\ntop jugadores en el mercado".grey.bold
    market_players.each do |player|
      puts "#{player[:position]} #{player[:name]} - #{player[:points]} points - #{player[:value]}"
    end

    puts "\ntransferencias recientes".grey.bold
    recent_transfers.each do |transfer|
      target = "(#{transfer[:from]} → #{transfer[:to]})"
      if transfer[:from] == $MARKET_NAME then
        target = "(#{"+".green} #{transfer[:to]})"
      elsif transfer[:to] == $MARKET_NAME then
        target = "(#{"-".red} #{transfer[:from]})"
      end
      string = "#{"#{transfer[:position]} #{transfer[:player]}".ljust(20)} #{target.ljust(15)} #{transfer[:price]}€"

      if transfer[:from] == user_name then
        puts string.bold
      else
        puts string
      end
    end
  end
end
