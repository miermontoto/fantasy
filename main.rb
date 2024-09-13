require_relative 'token'
require_relative 'scraper'
require_relative 'browser'

browser = Browser.new
scraper = Scraper.new

scraper.feed(browser.feed.body)
