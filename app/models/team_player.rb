# Modelo que representa un jugador en el equipo
class TeamPlayer < Player
  # Atributos específicos de jugadores en el equipo
  attr_accessor :selected, :achieved, :being_sold, :own

  # Constructor de la clase, inicializa los atributos específicos del equipo
  def initialize(attributes = {})
    super(attributes)
    @selected = attributes[:selected] || false                                  # true si el jugador juega esta jornada
    @achieved = attributes[:achieved] || "?"                                    # puntos del jugador en la jornada actual (si aplica)
    @being_sold = attributes[:being_sold] || false                             # true si el jugador está en venta
    @own = true                                                                # siempre es propio
  end

  # Función que convierte un jugador del equipo a string
  def to_s
    content = base_string + [ points_string, @ppm.to_s ]
    content = content.map { |c| c.bold }                                       # siempre en negrita
    concat(content)
  end
end
