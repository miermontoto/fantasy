class OfferPlayer < Player
  attr_reader :best_bid, :offered_by, :raw_difference, :difference, :difference_trend, :own

  def initialize(attributes = {})
    super(attributes)

    @best_bid = attributes[:best_bid] || 0                                          # mejor oferta recibida
    @offered_by = attributes[:offered_by] || ""                                     # nombre del usuario que hace la oferta
    @raw_difference = @best_bid - @value                                            # diferencia bruta entre el valor y la mejor oferta
    @difference = (100 * ((@best_bid.to_f / @value) - 1)).round(2)                  # diferencia en porcentaje entre el valor y la mejor oferta
    @difference_trend = parse_difference_trend(@difference) if @difference.present? # tendencia de la diferencia
    @own = true                                                                     # siempre es propio

    if @offered_by.present? && @offered_by.include?(ApplicationHelper::MARKET_NAME)
      @offered_by = "Mercado"
    end
  end

  def to_s
    difference = "#{@raw_difference.positive? ? "+".green : "-".red}#{format_num(@raw_difference)}"
    offer = "€ #{format_num(@best_bid)} (#{difference}) (#{@difference_trend} #{@difference}%)"

    content = base_string + [ offer + " " + @offered_by.grey.italic ]
    concat(content)
  end
end
