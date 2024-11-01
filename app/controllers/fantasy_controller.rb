class FantasyController < ApplicationController
  def index
    browser = Browser.new
    @feed_data = Scraper.feed(browser.feed.body)
  end

  def market
    browser = Browser.new
    @market_data = Scraper.market(browser.market.body)
  end

  def team
    browser = Browser.new
    @team_data = Scraper.team(browser.team.body)
  end

  def standings
    browser = Browser.new
    @standings_data = Scraper.standings(browser.standings.body)
  end
end
