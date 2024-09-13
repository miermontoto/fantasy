require_relative '../helpers'
require_relative 'position'

class Player
  attr_accessor :name, :points, :team, :position, :value, :sell_price
  attr_accessor :seller, :trend, :average, :status, :streak

  def initialize(info)
    @name = info[:name]
    @points = info[:points]
    @team = info[:team]
    @position = Position.new(info[:position])
    @value = format_num(info[:value]) + '€'
    @sale = format_num(info[:sale]) + '€'
    @seller = info[:seller]
    @trend = info[:trend] == '↑' ? '↑'.green : '↓'.red
    @average = info[:average] ? info[:average].to_f.round(2) : ''
    @streak = "[#{info[:streak]}.join(', ')]"
    @status = info[:status] ? " [#{info[:status].upcase}] " : ""
  end

  def to_s
    name = "#{@name}#{@status}"
    price = "#{@value}#{" (#{@sale})" unless @sale == @value}"
    points = "#{@points}#{" (#{@average})" unless @average == ''}"

    string = "#{@position.to_s} #{name.ljust(25)} - #{points.ljust(8)} - #{@trend} #{price.ljust(24)}"
    if status != "" then
      string = string.italic
    end

    string
  end
end
