require 'nokogiri'
require 'curses'

require_relative 'helpers'
require_relative '../models/player'
require_relative '../models/transfer'
require_relative '../models/user'

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
      Player.new({
        name: player.css('.name').text.strip,
        # team: player.css('.team-logo')['src'],
        position: player.css('.icons i').attr('class').value,
        points: player.css('.points').text.strip,
        value: player.css('.underName').text.gsub(/[^0-9]/, ''),
        average: player.css('.avg').text.strip,
        streak: player.css('.streak span').map { |span| span.text.strip },
        trend: player.css('.value-arrow').text.strip
      })
    end

    # transferencias recientes
    recent_transfers = doc.css('.card-transfer').map do |block|
      date = block.css('.date').text.strip
      block.css('.player-list>li').map do |transfer|
        Transfer.new({
          player: transfer.css('.title strong').text.strip,
          position: transfer.css('.player-row .icons i').attr('class').value,
          from: transfer.css('.title em').first.text.strip,
          to: transfer.css('.title em').last.text.strip,
          price: transfer.css('.price').first.text.strip || 0,
          date: date,
          status: transfer.css('.status use')&.attr('href')&.value&.split('#')&.last,
          user: user_name
        })
      end
    end

    {
      data: {
        market_players: {
          title: "top mercado",
          content: market_players
        },
        recent_transfers: {
          title: "movimientos recientes",
          content: recent_transfers.flatten
        }
      },
      footer_info: {
        community: { title: "liga", data: community_name },
        balance: { title: "balance", data: user_balance },
        credits: { title: "créditos", data: user_credits },
        gameweek: { title: "jornada", data: "#{gameweek} (#{gameweek_status})" }
      }
    }
  end

  def market(html)
    doc = Nokogiri::HTML(html)

    players = doc.css('#list-on-sale li').map do |player|
      Player.new({
        id: player.css('.player-pic.qd-player').attr('data-id_player').value,
        name: player.css('.name').text.strip,
        seller: player.css('.date').text.strip,
        position: player.css('.icons i').attr('class').value,
        points: player.css('.points').text.strip.to_i,
        value: player.css('.underName').text.gsub(/[^0-9]/, '').to_i,
        trend: player.css('.value-arrow').text.strip,
        average: player.css('.avg').text.strip,
        streak: player.css('.streak span').map { |span| span.text.strip },
        status: player.css('.status use')&.attr('href')&.value&.split('#')&.last,
        sale: player.css('.player-btns .btn-bid').text.gsub(/[^0-9]/, '').to_i
      })
    end

    players = sort_players(players)

    footer_info = {
      current_balance: format_num(doc.css('.footer-sticky-market .balance-real-current').text.gsub(/\./, '').to_i),
      future_balance: format_num(doc.css('.balance-real-future').text.gsub(/\./, '').to_i),
      max_debt: format_num(doc.css('.balance-real-maxdebt').text.gsub(/\./, '').to_i),
      next_update: doc.css('.next-update').text.split('en').last.strip
    }

    {
      data: {
        players: {
          title: "mercado",
          content: sort_players(players)
        }
      },
      footer_info: {
        current_balance: { title: "balance actual", data: footer_info[:current_balance] },
        future_balance: { title: "balance futuro", data: footer_info[:future_balance] },
        max_debt: { title: "deuda máxima", data: footer_info[:max_debt] },
        next_update: { title: "siguiente ciclo", data: footer_info[:next_update] }
      }
    }
  end

  def standings(html)
    doc = Nokogiri::HTML(html)

    total = doc.css('.panel-total li').map do |user|
      User.new({
        position: user.css('.position').text.strip,
        name: user.css('.name').text.strip,
        players: user.css('.played').text.split('·').first.strip.split(' ').first.to_i,
        value: user.css('.played').text.split('·').last.strip.gsub(/[^0-9]/, '').to_i,
        points: user.css('.points:not(span)').text.split(' ').first.strip.to_i,
        diff: user.css('.diff').text.strip
      })
    end

    gameweek = doc.css('.panel-gameweek li').map do |user|
      User.new({
        position: user.css('.position').text.strip,
        name: user.css('.name').text.strip,
        players: user.css('.played').text.split(' · ').first.strip,
        value: user.css('.played').text.split(' · ').last.strip.gsub(/[^0-9]/, '').to_i,
        points: user.css('.points:not(span)').text.split(' ').first.strip.to_i,
      })
    end

    jornada = doc.css('.top select option[selected]').text.strip

    {
      data: {
        total: {
          title: "total",
          content: total
        },
        gameweek: {
          title: "jornada",
          content: gameweek
        }
      },
      footer_info: {
        jornada: { title: "jornada actual", data: jornada }
      }
    }
  end

  def team(html)
    doc = Nokogiri::HTML(html)

    squad_players = doc.css('.player-list.list-team li').map do |player|
      Player.new({
        name: player.css('.name').text.strip.gsub(/\s+/, ' '),
        position: player.css('.icons i').attr('class').value,
        points: player.css('.points').text.strip,
        value: player.css('.underName').text.gsub(/[^\d]/, '').to_i,
        average: player.css('.avg').text.strip,
        streak: player.css('.streak span').map { |span| span.text.strip },
        trend: player.css('.value-arrow').text.strip
      })
    end

    {
      data: {
        squad_players: {
          title: "plantilla",
          content: squad_players
        }
      },
      footer_info: {
        value: { title: "valor", data: doc.css('.squad-info .subtitle').text.split('·').last.strip },
        average: { title: "media", data: doc.css('.team-avg span').first.text.strip },
        player_count: { title: "jugadores", data: "#{doc.css('.squad-info .subtitle').text.split('·').first.strip.split(' ').first.to_i}" }
      }
    }
  end
end
