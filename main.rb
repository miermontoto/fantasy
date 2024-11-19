#!/usr/bin/env ruby

if ARGV[0] == 'server'
  require 'rails/commands'
else
  require File.expand_path('../config/environment', __FILE__)

  browser = Browser.new
  scraper = Scraper.new

  endpoints = [ 'feed', 'market', 'standings', 'team', 'offers', 'communities' ]
  action = ARGV[0] || 'feed'

  if endpoints.include?(action)
    response = browser.send(action)
    scraper.send(action, response.body)
  else
    puts "acción inválida [#{endpoints.join(', ')}]"
  end
end
