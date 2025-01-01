class TeamPlayer < Player
  attr_reader :selected, :achieved, :being_sold, :own

  def initialize(attributes = {})
    super(attributes)

    @selected = attributes[:selected] || false                                  # true si el jugador juega esta jornada
    @achieved = attributes[:achieved] || "?"                                    # puntos del jugador en la jornada actual (si aplica)
    @being_sold = attributes[:being_sold] || false                              # true si el jugador está en venta
    @own = true                                                                 # siempre es propio
  end

  # Función que convierte un jugador del equipo a string
  def to_s
    content = base_string + [ points_string, @ppm.to_s ]
    concat(content)
  end
end
