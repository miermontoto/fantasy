require_relative 'lib/scraper'
require_relative 'lib/browser'

browser = Browser.new
scraper = Scraper.new

endpoints = ['feed', 'market', 'standings', 'team']
action = ARGV[0] || 'feed'

if endpoints.include?(action) then
  response = browser.send(action)
  scraper.send(action, response.body)
else
  puts "acción inválida [#{endpoints.join(', ')}]"
end
