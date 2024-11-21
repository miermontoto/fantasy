# Modelo que representa un jugador, ya sea en el mercado, en el equipo o en una
# transferencia.
class Player
  include ApplicationHelper

  # @todo revisar si se puede usar attr_reader en vez de attr_accessor
  attr_accessor :position, :name, :points, :value, :average, :price, :ppm, :id,
                :trend, :streak, :status, :own, :player_img, :team_img,
                :transfer_div, :clause

  # Constructor de la clase, inicializa los atributos del jugador
  # a partir de un hash de atributos proporcionado por el scraper
  def initialize(attributes = {})
    @position = Position.new(attributes[:position])                              # posición del jugador
    @name = attributes[:name].gsub('💥', '')                                     # nombre del jugador
    @points = attributes[:points].to_s || "0"                                    # puntos del jugador en toda la temporada actual
    @value = attributes[:value]                                                  # valor actual del jugador en el mercado
    @average = attributes[:average]                                              # media de puntos por partido
    @price = format_num(@value)                                                  # valor formateado actual del jugador en el mercado
    @ppm = calculate_ppm                                                         # puntos por millón de valor
    @id = attributes[:id]                                                        # id del jugador
    @trend = attributes[:trend] ? parse_trend(attributes[:trend]) : ""           # tendencia del jugador
    @streak = attributes[:streak]                                                # array de los puntos de los últimos tres partidos
    @status = attributes[:status] ? parse_status(attributes[:status]) : ""       # estado del jugador
    @own = attributes[:own] || false                                             # true si el jugador es del usuario
    @user = attributes[:user]                                                    # nombre del usuario
    @player_img = attributes[:player_img] || ""                                  # url de la imagen del jugador
    @team_img = attributes[:team_img] || ""                                      # url de la imagen del equipo del jugador

    @is_transfer = attributes[:transfer] || false                                # en transferencia: true
    @from = attributes[:from] || ""                                              # en transferencia: origen
    @to = attributes[:to] || ""                                                  # en transferencia: destino
    @clause = attributes[:clause] || false                                       # en transferencia: true si la transferencia es por pago de cláusula
    @from_market = @from == ApplicationHelper::MARKET_NAME unless @from.nil?     # en transferencia: true si el origen es el mercado
    @to_market = @to == ApplicationHelper::MARKET_NAME unless @to.nil?           # en transferencia: true si el destino es el mercado

    @is_offer = attributes[:offer] || false                                      # en oferta: true
    @previous_value = attributes[:previous_value] || 0                           # en oferta: valor anterior del jugador
    @best_bid = attributes[:best_bid] || 0                                       # en oferta: mejor oferta
    @offered_by = attributes[:offered_by] || ""                                  # en oferta: nombre del usuario que ofrece el jugador
    @bid_status = attributes[:bid_status] || ""                                  # en oferta: estado de la oferta
    @asked_price = attributes[:asked_price] || 0                                 # en oferta: precio de la oferta

    @variation = @value - @previous_value if @is_offer                           # en oferta: variación diaria del valor
    @raw_difference = @best_bid - @value if @is_offer                            # en oferta: diferencia bruta entre el valor y la mejor oferta
    @difference = (100 * ((@best_bid.to_f / @value) - 1)).round(2) if @is_offer  # en oferta: diferencia en porcentaje entre el valor y la mejor oferta
    @increase_trend = increase_trend(@variation) if @variation
    @difference_trend = difference_trend(@difference) if @difference

    @transfer_div = "
    <p class=\"text-sm #{@from_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@from}</p>
    <span class=\"mx-2 text-xl #{@from_market ? 'text-green-500' : @to_market ? 'text-red-500' : 'text-white'}\">&rarr;</span>
    <p class=\"text-sm #{@to_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@to}</p>
    " if @is_transfer

    price_trend = @increase_trend ? @increase_trend : @trend
    @price_string = price_trend == "" ? "" : "#{price_trend} "
    @price_string += "#{@price}€"
    @price_string += " (#{format_num(@variation)}€)" if @variation

    # calcular longitudes máximas de los atributos
    max("name", @name)
    max("points", @points)
    max("average", @average)
    max("price", @price_string)
  end

  private

  def base_string
    [
      @position.to_s,
      @name.ljust(max("name")) + " #{@status == "" ? " " : @status}",
      @price_string.ljust(max("price"))
    ]
  end

  # Función que calcula los puntos por millón de un jugador
  def calculate_ppm
    return 0 if @points.to_i == 0 || @value.to_i == 0
    (@points.to_i.to_f / @value.to_i * 1000000).round(2)
  end

  # Función que convierte un jugador a string
  def to_s
    # si el jugador es una transferencia, usar la función transfer_to_s
    if @is_transfer then; return transfer_to_s; end

    # si el jugador es una oferta, usar la función to_s_offer
    if @is_offer then; return to_s_offer; end

    # construir cadenas específicas para el jugador
    points = "#{@points.ljust(max("points"))}#{" (#{@average})".rjust(max("average") + 3) unless @average == ''}"

    # construir la cadena del jugador
    content = base_string + [
      points,
      @ppm.to_s
    ]

    # aplicar estilos en situaciones específicas
    if @points.to_i == 0 then # jugadores de mierda
      content = content.map { |c| c.grey }
    elsif @own then # jugador propio
      content = content.map { |c| c.bold }
    end

    # concatenar la cadena del jugador
    concat(content)
  end

  # Función que convierte un jugador en transferencia a string
  def transfer_to_s
    target = "#{@clause ? "💰" : ""} #{@from} → #{@to}"
    if @from_market then
      target = "#{"+".green} #{@to}"
    elsif @to_market then
      target = "#{"-".red} #{@from}"
    end

    info = "#{target}, #{@date}" # @todo usar info cuando se arregle date

    content = base_string + [
      target
    ]

    if @own then # transferencia propia en negrita
      content = content.map { |c| c.bold }
    end

    concat(content)
  end

  def to_s_offer
    offer = "#{format_num(@best_bid)}€ (#{@raw_difference}) (#{@difference_trend} #{@difference}%)" if @difference

    content = base_string + [
      offer + " " + @offered_by.grey.italic
    ]

    concat(content)
  end
end

# Función que ordena los jugadores por posición, media y valor (en ese orden)
def sort_players(players)
  players.sort_by { |player| [ player.position.to_i, -player.average.to_f, player.value.to_i ] }
end
