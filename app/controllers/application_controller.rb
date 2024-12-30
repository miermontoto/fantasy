class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_communities
  before_action :check_xauth_token

  private

  def set_communities
    browser = Browser.new
    scraper = Scraper.new(false)
    response = browser.communities
    result = scraper.communities(response.body)
    @communities = result[:communities]
  rescue JSON::ParserError
    # If we can't parse the response, it might be due to an invalid token
    @communities = []
    @needs_xauth = true
  end

  def check_xauth_token
    current_community = Token.get_current_community rescue nil
    if current_community && !Token.get_xauth(current_community)
      @needs_xauth = true
      @current_community_id = current_community
    end
  end
end
