class Player
  include ApplicationHelper

  attr_accessor :position, :name, :points, :value, :average, :price, :ppm, :id,
                :trend, :streak, :status, :own, :player_img, :transfer_div

  def initialize(attributes = {})
    @position = Position.new(attributes[:position])                              # posición del jugador
    @name = attributes[:name]                                                    # nombre del jugador
    @points = attributes[:points].to_s || "0"                                    # puntos del jugador en toda la temporada actual
    @value = attributes[:value]                                                  # valor actual del jugador en el mercado
    @average = attributes[:average]                                              # media de puntos por partido
    @price = format_num(@value)                                                  # valor formateado actual del jugador en el mercado
    @ppm = calculate_ppm                                                         # puntos por millón de valor
    @id = attributes[:id]                                                        # id del jugador
    @trend = attributes[:trend] ? parse_trend(attributes[:trend]) : ""           # tendencia del jugador
    @streak = attributes[:streak]                                                # array de los puntos de los últimos tres partidos
    @status = attributes[:status] ? parse_status(attributes[:status]) : ""       # estado del jugador
    @own = attributes[:own]
    @user = attributes[:user]
    @player_img = attributes[:player_img] || ""
    @from = attributes[:from] || ""
    @to = attributes[:to] || ""
    @is_transfer = attributes[:transfer] || false

    from_market = @from == self.class::MARKET_NAME unless @from.nil?
    to_market = @to == self.class::MARKET_NAME unless @to.nil?

    @transfer_div = "
    <p class=\"text-sm #{from_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@from}</p>
    <span class=\"mx-2 text-xl #{from_market ? 'text-green-500' : to_market ? 'text-red-500' : 'text-white'}\">&rarr;</span>
    <p class=\"text-sm #{to_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@to}</p>
    " if @is_transfer

    max("name", @name)
    max("points", @points)
    max("average", @average)
    max("price", @price)
  end

  private

  def max(key, value = nil)
    return @MAXES[key] if value.nil?

    @MAXES ||= {}
    length = value.to_s.length
    @MAXES[key] = length if @MAXES[key].nil? || length > @MAXES[key]
  end

  def calculate_ppm
    return 0 if @points.to_i == 0 || @value.to_i == 0
    (@points.to_i.to_f / @value.to_i * 1000000).round(2)
  end

  def to_s
    if @is_transfer then; return transfer_to_s; end
    points = "#{@points.ljust(max("points"))}#{" (#{@average})".rjust(max("average") + 3) unless @average == ''}"
    name_offset = @status == "" ? 1 : 0

    price_info = "#{@trend} #{@price}€"

    content = [
      @position.to_s,
      @name.ljust(max("name") + name_offset) + " " + @status.to_s,
      points,
      price_info.ljust(max("price") + 3),
      @ppm.to_s
    ]
    if @points.to_i == 0 then # jugadores de mierda
      content = content.map { |c| c.grey }
    elsif @own then
      content = content.map { |c| c.bold }
    end
    concat(content)
  end
end

def transfer_to_s
  target = "#{@from} → #{@to}"
    if @from == $MARKET_NAME then
      target = "#{"+".green} #{@to}"
    elsif @to == $MARKET_NAME then
      target = "#{"-".red} #{@from}"
    end

    info = "#{target}, #{@date}"

    content = [
      @position.to_s,
      @name.ljust(max("name")),
      (@price + "€").ljust(max("price") + 1),
      target
    ]
    if @own then # transferencia propia en negrita
      content = content.map { |c| c.bold }
    end

    content.compact.join(self.class::SEPARATOR)
end

def sort_players(players)
  players.sort_by { |player| [ player.position.to_i, -player.average.to_f, player.value.to_i ] }
end
