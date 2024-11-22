#!/usr/bin/env ruby

if ARGV[0] == 'server'
  require 'rails/commands'
else
  require File.expand_path('../config/environment', __FILE__)

  browser = Browser.new
  scraper = Scraper.new

  endpoints = [ 'feed', 'market', 'standings', 'team', 'offers' ]
  action = ARGV[0] || 'feed'

  if endpoints.include?(action)
    response = browser.send(action)
    scraper.send(action, response.body)
  elsif action == 'communities'
    if ARGV.length > 1 then
      browser.change_community(ARGV[1])
    else
      response = browser.communities
      scraper.communities(response.body)
    end
  else
    puts "acción inválida [#{endpoints.join(', ')}]"
  end
end
