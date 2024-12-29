class FantasyController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :set_xauth ]

  layout "application"

  def initialize
    super

    @scraper = Scraper.new(false)
    @browser = Browser.new
  end

  def index
    raw_data = @scraper.feed(@browser.feed.body)

    @market_data = raw_data[:market]
    @events_data = raw_data[:events]
    @standings_data = @scraper.standings(@browser.standings.body)
    @general_info = raw_data[:info]

    # Sort events by relative time
    @events_data = @events_data.sort_by do |event|
      time_str = event.raw_date.downcase

      # Convert relative time to minutes
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

    # Get top 5 market players by points
    @paginated_market_data = @market_data.sort_by { |player| -player.points.to_i }.first(5)

    # Paginate events data
    @current_page_feed = [ params[:page_feed].to_i, 1 ].max
    @per_page_feed = 5
    @total_pages_feed = [ (@events_data.size.to_f / @per_page_feed).ceil, 1 ].max
    @current_page_feed = [ @current_page_feed, @total_pages_feed ].min
    start_idx_feed = (@current_page_feed - 1) * @per_page_feed
    @paginated_feed_data = @events_data[start_idx_feed, @per_page_feed] || []

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("left-container",
          partial: "fantasy/partials/transfer_list",
          locals: {
            paginated_feed_data: @paginated_feed_data,
            paginated_market_data: @paginated_market_data,
            current_page_feed: @current_page_feed,
            total_pages_feed: @total_pages_feed
          }
        )
      end
    end
  end

  def market
    @market_data = @scraper.market(@browser.market.body)
    return render_empty_market unless @market_data && @market_data[:market]

    @filtered_market = @market_data[:market].dup

    # Apply filters
    apply_position_filter
    apply_price_filter
    apply_search_filter
    apply_source_filter
    apply_own_players_filter
    apply_sorting

    # Pagination
    @page = [ params[:page].to_i, 1 ].max
    @per_page = 10
    @total_pages = [ (@filtered_market.size.to_f / @per_page).ceil, 1 ].max
    @page = [ @page, @total_pages ].min

    start_idx = (@page - 1) * @per_page
    @filtered_market = @filtered_market[start_idx, @per_page] || []

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("market-content",
          partial: "fantasy/partials/market_content",
          locals: {
            market_players: @filtered_market,
            page: @page,
            total_pages: @total_pages
          }
        )
      end
    end
  end

  def team
    @team_data = @scraper.team(@browser.team.body)
  end

  def standings
    @standings_data = @scraper.standings(@browser.standings.body)
  end

  def events
    # Get events data from index action
    raw_data = @scraper.feed(@browser.feed.body)
    @events_data = raw_data[:events]

    # Sort events by relative time
    @events_data = @events_data.sort_by do |event|
      time_str = event.raw_date.downcase

      # Convert relative time to minutes
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

    # Pagination
    @page = (params[:page] || 1).to_i
    @per_page = 5
    @total_pages = (@events_data.size.to_f / @per_page).ceil
    @page = 1 if @page > @total_pages

    start_idx = (@page - 1) * @per_page
    @paginated_events = @events_data[start_idx, @per_page] || []

    respond_to do |format|
      format.html
      format.turbo_stream {
        render turbo_stream: turbo_stream.update("events-results", partial: "fantasy/partials/events_list", locals: {
          events_data: @paginated_events,
          page: @page,
          total_pages: @total_pages
        })
      }
    end
  end

  def render_players
    @filtered_market = JSON.parse(params[:players])
    @page = params[:page].to_i
    @total_pages = params[:total_pages].to_i

    render turbo_stream: [
      turbo_stream.update("market-results",
        partial: "fantasy/partials/market_players",
        locals: { market_players: @filtered_market }
      ),
      turbo_stream.update("market-pagination",
        partial: "fantasy/partials/pagination",
        locals: {
          id: "market-pagination",
          current_page: @page,
          total_pages: @total_pages,
          type: "market"
        }
      )
    ]
  rescue JSON::ParserError
    render turbo_stream: turbo_stream.update("market-results",
      partial: "fantasy/partials/market_players",
      locals: { market_players: [] }
    )
  end

  def render_events
    @events_data = JSON.parse(params[:events])
    @page = params[:page].to_i
    @total_pages = params[:total_pages].to_i

    render turbo_stream: turbo_stream.update("events-content",
      partial: "fantasy/partials/events_content",
      locals: {
        events_data: @events_data,
        page: @page,
        total_pages: @total_pages
      }
    )
  rescue JSON::ParserError
    render turbo_stream: turbo_stream.update("events-content",
      partial: "fantasy/partials/events_content",
      locals: {
        events_data: [],
        page: 1,
        total_pages: 1
      }
    )
  end

  def change_community
    @browser.change_community(params[:id])
    redirect_back(fallback_location: root_path)
  end

  def set_xauth
    community_id = params[:id]
    token = params[:token]

    if community_id.present? && token.present?
      Token.set_xauth(community_id, token)
      render json: { status: "success" }
    else
      render json: { status: "error", message: "Missing parameters" }, status: :bad_request
    end
  end

  private

  def apply_position_filter
    if params[:position].present?
      @filtered_market.select! { |player| player.position.browser[:position] == params[:position] }
    end

    if params[:exclude_position].present?
      excluded = params[:exclude_position].split(",")
      @filtered_market.reject! { |player| excluded.include?(player.position.browser[:position]) }
    end
  end

  def apply_price_filter
    if params[:max_price].present? && params[:max_price].to_i > 0
      max_price = params[:max_price].to_i
      @filtered_market.select! { |player| player.price.to_i <= max_price }
    end
  end

  def apply_search_filter
    if params[:search].present?
      search_term = params[:search].downcase.strip
      @filtered_market.select! { |player| player.name.downcase.include?(search_term) }
    end
  end

  def apply_sorting
    sort_by = params[:sort_by].presence || "points"
    direction = (params[:sort_direction] || "desc") == "asc" ? 1 : -1

    @filtered_market.sort_by! do |player|
      value = case sort_by
      when "points" then player.points.to_i
      when "avg" then player.average.to_s.tr(",", ".").to_f
      when "ppm" then player.ppm.to_f
      when "price" then player.price.to_i
      when "streak" then
          if player.streak.is_a?(Array)
            player.streak.map { |p| p.to_i }.sum
          else
            0
          end
      else 0
      end
      value * direction
    end
  end

  def apply_own_players_filter
    # Hide own players by default (when nil) or when explicitly checked (value = "1")
    if params[:own_players].nil? || params[:own_players] == "1"
      @filtered_market.reject! { |player| player.own }
    end
  end

  def apply_source_filter
    return if params[:source].nil? || params[:source] == "all"

    case params[:source]
    when "free"
      @filtered_market.select! { |player| player.offered_by == "Libre" }
    when "users"
      @filtered_market.reject! { |player| player.offered_by == "Libre" }
    end
  end

  def render_empty_market
    respond_to do |format|
      format.html { redirect_to root_path, alert: "No se pudo cargar el mercado" }
      format.turbo_stream {
        render turbo_stream: turbo_stream.update("market-content",
          partial: "fantasy/partials/market_content",
          locals: {
            market_players: [],
            page: 1,
            total_pages: 1
          }
        )
      }
    end
  end
end
