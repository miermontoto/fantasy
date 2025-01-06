#!/usr/bin/env ruby

if ARGV[0] == 'server'
  require 'rails/commands'
else
  require File.expand_path('../config/environment', __FILE__)

  browser = Browser.new
  scraper = Scraper.new

  endpoints = [ 'feed', 'market', 'standings', 'team', 'offers', 'top_market', 'top_players' ]
  action = ARGV[0] || 'feed'

  if action == 'communities'
    if ARGV.length > 1 then
      browser.change_community(ARGV[1])
    else
      response = browser.communities
      scraper.communities(response.body)
    end
  elsif action == 'player'
    response = browser.player(ARGV[1])
    scraper.player(response.body, nil)
  elsif endpoints.include?(action)
    response = browser.send(action)
    scraper.send(action, response.body)
  else
    puts "acción inválida [#{endpoints.join(', ')}]"
  end
end
