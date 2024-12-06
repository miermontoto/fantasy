class FantasyController < ApplicationController
  layout "application"

  def index
    browser = Browser.new

    raw_data = Scraper.new.feed(browser.feed.body)

    @market_data = raw_data[:market]
    @events_data = raw_data[:events]
    @standings_data = Scraper.new.standings(browser.standings.body)

    # Pagination parameters for market data
    market_page = params[:page_market].present? ? params[:page_market].to_i : 1
    per_page_market = 5

    @total_pages_market = (@market_data.size / per_page_market.to_f).ceil
    @paginated_market_data = @market_data.slice((market_page - 1) * per_page_market, per_page_market) || []
    @current_page_market = market_page

    # Pagination parameters for feed data
    feed_page = params[:page_feed].present? ? params[:page_feed].to_i : 1
    per_page_feed = 5

    # hay que filtrar los eventos teniendo en cuenta que no se tienen "fechas"
    # como tal, sino que se tiene una cadena con el tiempo relativo a la fecha
    # actual, ej: hace 13 minutos, hace 2 horas, hace 1 día, etc.
    sorted_events = @events_data.sort_by do |event|
      time_str = event.raw_date.downcase

      # convertir el tiempo relativo a minutos
      case time_str
      when /^hace (\d+) segundos?$/
        $1.to_i / 60
      when /^hace (\d+) minutos?$/
        $1.to_i
      when /^hace (\d+) horas?$/
        $1.to_i * 60
      when /^hace (\d+) días?$/
        $1.to_i * 24 * 60
      else # panic!
        Float::INFINITY
      end
    end

    @total_pages_feed = (sorted_events.size / per_page_feed.to_f).ceil
    @paginated_feed_data = sorted_events.slice((feed_page - 1) * per_page_feed, per_page_feed) || []
    @current_page_feed = feed_page

    # Si la peticion es AJAX, renderizar la vista parcial
    if request.xhr?
      render partial: "fantasy/partials/transfer_list", locals: {
        paginated_feed_data: @paginated_feed_data,
        paginated_market_data: @paginated_market_data,
        current_page_feed: @current_page_feed,
        total_pages_feed: @total_pages_feed,
        current_page_market: @current_page_market,
        total_pages_market: @total_pages_market
      }
    else
      respond_to do |format|
        format.html
      end
    end
  end

  def market
    browser = Browser.new
    @market_data = Scraper.new.market(browser.market.body)
  end

  def team
    browser = Browser.new
    @team_data = Scraper.new.team(browser.team.body)
  end

  def standings
    browser = Browser.new
    @standings_data = Scraper.new.standings(browser.standings.body)
  end
end
