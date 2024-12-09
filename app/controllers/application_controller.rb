class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_communities

  private

  def set_communities
    browser = Browser.new
    scraper = Scraper.new(false)
    response = browser.communities
    @communities = scraper.communities(response.body)[:communities]
  end
end
