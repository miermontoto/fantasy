class TransferPlayer < Player
  attr_reader :from, :to, :date, :clause, :own, :other_bids, :from_market, :to_market

  def initialize(attributes = {})
    super(attributes)

    @from = attributes[:from] || ""                                             # origen de la transferencia
    @to = attributes[:to] || ""                                                 # destino de la transferencia
    @date = attributes[:date] || ""                                             # fecha de la transferencia
    @clause = attributes[:clause] || false                                      # true si la transferencia es por pago de cláusula
    @own = attributes[:own] || false                                            # true si el jugador es propio
    @from_market = @from == ApplicationHelper::MARKET_NAME                      # true si el origen es el mercado
    @to_market = @to == ApplicationHelper::MARKET_NAME                          # true si el destino es el mercado
    @other_bids = attributes[:other_bids]                                       # otras pujas del jugador
  end

  def to_s
    target = "#{@clause ? "💰" : ""} #{@from} → #{@to}"
    if @from_market
      target = "#{"+".green} #{@to}" # compra desde el mercado
    elsif @to_market
      target = "#{"-".red} #{@from}" # venta al mercado
    end

    content = base_string + [ target ]
    content = content.map { |c| c.bold } if @own # transferencia propia en negrita
    concat(content)
  end
end
