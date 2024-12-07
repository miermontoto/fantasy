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

    # Apply filters
    @market_data[:market] = @market_data[:market].select do |player|
      matches = true
      if params[:position].present?
        matches &= player.position.to_s == params[:position]
      end
      if params[:exclude_position].present?
        excluded = params[:exclude_position].split(',')
        matches &= !excluded.include?(player.position.to_s)
      end
      matches &= player.value <= params[:max_price].to_i if params[:max_price].present?
      matches &= player.name.downcase.include?(params[:search].downcase) if params[:search].present?
      matches
    end

    # Apply sorting
    sort_by = params[:sort] || 'points_desc'
    @market_data[:market] = @market_data[:market].sort_by do |player|
      case sort_by
      when 'price_asc' then player.value
      when 'price_desc' then -player.value
      when 'points_desc' then -player.points.to_i
      when 'avg_desc' then -player.average.to_f
      when 'ppm_desc' then -player.ppm
      else -player.points.to_i # Default to points_desc
      end
    end

    # Pagination
    @current_page = (params[:page] || 1).to_i
    per_page = 10
    total_items = @market_data[:market].size
    @total_pages = (total_items.to_f / per_page).ceil

    start_idx = (@current_page - 1) * per_page
    @market_data[:market] = @market_data[:market][start_idx, per_page] || []

    respond_to do |format|
      format.html
      format.turbo_stream if turbo_frame_request?
    end
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
