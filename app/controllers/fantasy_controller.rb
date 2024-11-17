class FantasyController < ApplicationController
  layout "application"

  def index
    browser = Browser.new
    @feed_data = Scraper.new.feed(browser.feed.body)

    respond_to do |format|
      format.html
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
