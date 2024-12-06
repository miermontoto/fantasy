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

    @total_pages_feed = (@events_data.size / per_page_feed.to_f).ceil
    @paginated_feed_data = @events_data.slice((feed_page - 1) * per_page_feed, per_page_feed) || []
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
