# Modelo que representa un jugador, ya sea en el mercado, en el equipo o en una
# transferencia.
class Player
  include ApplicationHelper

  # Atributos comunes a todos los tipos de jugadores
  attr_reader :id, :position, :name, :points, :value, :average, :price, :ppm,
                :trend, :streak, :status, :player_img, :team_img, :rival_img,
                :values, :goals, :matches, :owners, :gpm, :clauses_rank,
                :market_ranks

  # Constructor de la clase, inicializa los atributos del jugador
  # a partir de un hash de atributos proporcionado por el scraper
  def initialize(attributes = {})
    @id = attributes[:id]
    @position = Position.new(attributes[:position])                             # posición del jugador
    @name = attributes[:name].gsub("💥", "")                                    # nombre del jugador
    @points = attributes[:points].to_s || "0"                                   # puntos del jugador en toda la temporada actual
    @value = attributes[:value].to_s.gsub(".", "").to_i || 0                    # valor actual del jugador en el mercado
    @average = attributes[:average]                                             # media de puntos por partido
    @price = "€ " + format_num(@value)                                          # valor formateado actual del jugador en el mercado
    @ppm = calculate_ppm                                                        # puntos por millón de valor
    @trend = attributes[:trend] || ""                                           # tendencia del jugador
    @streak = attributes[:streak]                                               # array de los puntos de los últimos tres partidos
    @status = Status.new(attributes[:status])                                   # estado del jugador
    @player_img = attributes[:player_img] || ""                                 # url de la imagen del jugador
    @team_img = attributes[:team_img] || ""                                     # url de la imagen del equipo del jugador
    @rival_img = attributes[:rival_img] || ""                                   # url de la imagen del próximo equipo rival
    @market_ranks = attributes[:market_ranks] || {}                             # array de las posiciones en el ranking de subidas y bajadas de valor

    if @trend.present? and @trend == "" then; @trend = "~"; end
    get_price_string

    # calcular longitudes máximas de los atributos
    max("name", @name)
    max("points", @points)
    max("average", @average)
    max("price", @price_string)
  end

  # Función que convierte un jugador a string
  def to_s
    concat(base_string + [ points_string, @ppm.to_s ])
  end

  def load_additional_attributes(content)
    @goals = content[:goals]
    @matches = content[:matches]
    @gpm = (@goals.to_i.to_f / @matches.to_i).round(3) unless @matches.to_i == 0
    @clauses_rank = content[:clauses_rank]
    @market_ranks = content[:market_ranks]

    load_relative_values(content[:values]) if content[:values].present?
    load_previous_owners(content[:owners]) if content[:owners].present?

    @transfer = content[:transfer]
  end

  def load_rank(players)
    same_player = players.find { |player| player.id.to_i == @id.to_i }

    if same_player.present?
      @market_ranks = same_player.market_ranks
    end
  end

  protected

  # Función que devuelve el array base de strings para mostrar un jugador
  def base_string
    [
      @position.to_s,
      @name.ljust(max("name")) + " #{@status == "" ? " " : @status}",
      @price_string.rjust(max("price"))
    ]
  end

  # Función que devuelve el string de puntos de un jugador
  def points_string
    "#{@points.ljust(max("points"))}#{" (#{@average})".rjust(max("average") + 3) unless @average == ''}"
  end

  # Función que calcula los puntos por millón de un jugador
  def calculate_ppm
    return 0 if @points.to_i == 0 || @value.to_i == 0
    (@points.to_i.to_f / @value.to_i * 1000000).round(1)
  end

  # Función que formatea la tendencia del precio de un jugador
  def get_price_string
    price_trend = parse_trend(@trend)
    @price_string = "#{@price} "
    @price_string += price_trend unless price_trend == ""
    @price_string += " (#{format_num(@variation)}€)" if @variation
  end

  # Función que procesa el array de valores relativos del jugador
  def load_relative_values(arr)
    # validación inicial básica
    if !arr.is_a?(Array) or arr.empty? then; return []; end

    # tiene que tener la siguiente forma:
    #
    # [
    #  {
    #    "change": int,
    #    "sign": string|int,
    #    "time": "Un día" | "Una semana" | "Un mes" | "Un año",
    #    "value": int
    #  },
    #  ...
    # ]

    # procesar los datos de manera que queda de la siguiente forma:
    #
    # [
    #   {
    #     "timespan": 0|1|2|3,
    #     "value": int,
    #     "change": int,
    #   },
    #   ...
    # ]
    @values = arr.each do |item|
      item["tiemspan"] = case item["time"]
      when "Un día" then 0
      when "Una semana" then 1
      when "Un mes" then 2
      when "Un año" then 3
      end

      item["value"] = item["value"].to_i
      item["change"] = item["change"].to_i
    end

    @values
  end

  # Función que carga el array de propietarios anteriores
  def load_previous_owners(arr)
    @owners = arr.map do |item|
      {
        date: item["date"],
        from: item["from"],
        to: item["to"],
        price: item["price"],
        type: item["transferType"]
      }
    end
  end
end

# Función que ordena los jugadores por posición, media y valor (en ese orden)
def sort_players(players)
  players.sort_by { |player| [ player.position.to_i, -player.average.to_f, player.value.to_i ] }
end
