require 'colorize'

require_relative '../lib/helpers'

class User
  def initialize(info)
    @position = info[:position]
    @name = info[:name]
    @points = info[:points]
    @players = info[:players] || '-'.red
    @value = format_num(info[:value])
    @diff = info[:diff]
  end

  def to_s
    content = [@position, @name.ljust(20), @points.to_s.rjust(3), @players.to_s.rjust(3)]
    if not @diff.nil? then
      diff = @diff.to_i == 0 ? '←' : @diff
      content << @value.to_s.rjust(6)
      content << diff.to_s.rjust(3)
    end
    content = content.map { |c| c.bold } unless @diff.nil? if @diff.to_i == 0
    concat(content)
  end
end
