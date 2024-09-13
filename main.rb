require_relative 'scraper'
require_relative 'browser'

browser = Browser.new
scraper = Scraper.new

endpoints = ['feed', 'market']
action = ARGV[0] || 'feed'

if endpoints.include?(action) then
  response = browser.send(action)
  scraper.send(action, response.body)
else
  puts "acción inválida [#{endpoints.join(', ')}]"
end
