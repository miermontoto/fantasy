class MarketPlayer < Player
  attr_reader :id, :owner, :asked_price, :offered_by, :own, :my_bid, :overprice

  def initialize(attributes = {})
    super(attributes)

    @id = attributes[:id]                                                       # id del jugador
    @owner = attributes[:owner] || ""                                           # dueño del jugador
    @asked_price = attributes[:asked_price] || @value                           # precio de venta del jugador
    @offered_by = attributes[:offered_by] || ApplicationHelper::FREE_AGENT      # nombre del usuario que ofrece el jugador
    @own = attributes[:own] || @asked_price == 0                                # true si el jugador es propio
    @my_bid = attributes[:my_bid] || nil                                        # precio de mi oferta

    @overprice = (@asked_price - @value) / @value.to_f * 100 if @asked_price.present?
  end

  def to_s
    content = base_string + [ points_string, @ppm.to_s ]
    content = content.map { |c| c.grey } if @points.to_i == 0 && !@average.nil? # jugadores de mierda
    content = content.map { |c| c.bold } if @own                                # jugador propio
    concat(content)
  end
end
