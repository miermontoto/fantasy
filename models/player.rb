require_relative '../helpers'
require_relative 'position'

$max_name_length = 0
$max_points_length = 0
$max_price_length = 0
$max_average_length = 0

class Player
  attr_reader :position, :value, :ppm, :average

  def initialize(info)
    @name = info[:name]
    @points = info[:points].to_s
    @team = info[:team]
    @position = Position.new(info[:position])
    @value = format_num(info[:value])
    @sale = format_num(info[:sale]) unless info[:sale].nil?
    @seller = info[:seller]
    @trend = info[:trend] == '↑' ? '↑ '.green : '↓ '.red
    @average = info[:average] ? info[:average].gsub!(',', '.').to_f.round(1) : ''
    @streak = "[#{info[:streak]}.join(', ')]"
    @status = status(info[:status])

    # points per million
    @ppm = (@points.to_f * 1000000 / info[:value].to_f).round(2)
    @own = @sale == '0€'
    @price = @trend + (@sale != nil && @sale != @value && !@own ? "(#{@sale})" : @value)

    $max_name_length = @name.length if @name.length > $max_name_length
    $max_points_length = @points.length if @points.length > $max_points_length
    $max_average_length = @average.to_s.length if @average.to_s.length > $max_average_length
    $max_price_length = @price.length if @price.length > $max_price_length
  end

  def to_s
    points = "#{@points.ljust($max_points_length)}#{" (#{@average})".rjust($max_average_length + 3) unless @average == ''}"
    name_offset = @status == '' ? 1 : 0

    content = [@position.to_s, @name.ljust($max_name_length + name_offset) + ' ' + @status, points, @price.ljust($max_price_length), @ppm.to_s]
    if @average == 0 then # jugadores de mierda
      content = content.map { |c| c.grey }
    elsif @own then
      content = content.map { |c| c.bold }
    end
    concat(content)
  end
end

def sort_players(players)
  # sort first by position, then by ppm, then by price
  players.sort_by { |player| [player.position.to_i, -player.average, player.value.to_i] }
end
