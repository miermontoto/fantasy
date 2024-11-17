class FantasyController < ApplicationController
  layout "application"

  def index
    browser = Browser.new

    @feed_data = Scraper.new.feed(browser.feed.body)[:transfers]
    @standings_data = Scraper.new.standings(browser.standings.body)

    # Parametros de paginacion
    page = params[:page].present? ? params[:page].to_i : 1
    per_page = 5

    # Calcular el total de paginas y obtener los datos paginados
    @total_pages = (@feed_data.size / per_page.to_f).ceil
    @paginated_feed_data = @feed_data.slice((page - 1) * per_page, per_page) || []

    # Si la peticion es AJAX, renderizar la vista parcial
    if request.xhr?
      render partial: "fantasy/partials/transfer_list", locals: { paginated_feed_data: @paginated_feed_data }
    else
      @current_page = page
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
