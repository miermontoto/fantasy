class Player
  include ApplicationHelper

  attr_accessor :position, :name, :points, :value, :average, :price, :ppm, :id,
                :seller, :trend, :streak, :status, :sale, :own, :player_img

  def initialize(attributes = {})
    @position = Position.new(attributes[:position])
    @name = attributes[:name]
    @points = attributes[:points]
    @value = attributes[:value]
    @average = attributes[:average]
    @price = format_num(@value)
    @ppm = calculate_ppm
    @id = attributes[:id]
    @seller = attributes[:seller]
    @trend = attributes[:trend]
    @streak = attributes[:streak]
    @status = attributes[:status] || ""
    @sale = attributes[:sale]
    @own = attributes[:own]
    @player_img = attributes[:player_img] || ""

    ApplicationHelper.max_name_length = @name.length if @name.length > ApplicationHelper.max_name_length
    ApplicationHelper.max_points_length = @points.to_s.length if @points.to_s.length > ApplicationHelper.max_points_length
    ApplicationHelper.max_average_length = @average.to_s.length if @average.to_s.length > ApplicationHelper.max_average_length
    ApplicationHelper.max_price_length = @price.to_s.length if @price.to_s.length > ApplicationHelper.max_price_length
  end

  private

  def calculate_ppm
    return 0 if @points.to_i == 0 || @value.to_i == 0
    (@points.to_i.to_f / @value.to_i * 1000000).round(2)
  end

  def to_s
    points = "#{@points.ljust($max_points_length)}#{" (#{@average})".rjust($max_average_length + 3) unless @average == ''}"
    name_offset = @status == "" ? 1 : 0

    content = [ @position.to_s, @name.ljust($max_name_length + name_offset) + " " + @status, points, @price.ljust($max_price_length), @ppm.to_s ]
    if @points.to_i == 0 then # jugadores de mierda
      content = content.map { |c| c.grey }
    elsif @own then
      content = content.map { |c| c.bold }
    end
    concat(content)
  end
end

def sort_players(players)
  players.sort_by { |player| [ player.position.to_i, -player.average.to_f, player.value.to_i ] }
end
