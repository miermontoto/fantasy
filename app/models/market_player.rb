# Modelo que representa un jugador en el mercado
class MarketPlayer < Player
  # Atributos específicos de jugadores en el mercado
  attr_accessor :id, :owner, :asked_price, :offered_by, :own

  # Constructor de la clase, inicializa los atributos específicos del mercado
  def initialize(attributes = {})
    super(attributes)
    @id = attributes[:id]                                                       # id del jugador
    @owner = attributes[:owner] || ""                                           # dueño del jugador
    @asked_price = attributes[:asked_price] || 0                                # precio de venta del jugador
    @offered_by = attributes[:offered_by] || ApplicationHelper::FREE_AGENT      # nombre del usuario que ofrece el jugador
    @own = attributes[:own] || false                                           # true si el jugador es propio
  end

  # Función que convierte un jugador del mercado a string
  def to_s
    content = base_string + [ points_string, @ppm.to_s ]
    content = content.map { |c| c.grey } if @points.to_i == 0 && !@average.nil?  # jugadores de mierda
    content = content.map { |c| c.bold } if @own                                 # jugador propio
    concat(content)
  end
end
