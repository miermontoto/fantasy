# Modelo que representa un jugador en una transferencia
class TransferPlayer < Player
  # Atributos específicos de jugadores en transferencia
  attr_accessor :from, :to, :date, :clause, :own, :transfer_div

  # Constructor de la clase, inicializa los atributos específicos de la transferencia
  def initialize(attributes = {})
    super(attributes)
    @from = attributes[:from] || ""                                            # origen de la transferencia
    @to = attributes[:to] || ""                                                # destino de la transferencia
    @date = attributes[:date] || ""                                            # fecha de la transferencia
    @clause = attributes[:clause] || false                                     # true si la transferencia es por pago de cláusula
    @own = attributes[:own] || false                                          # true si el jugador es propio
    @from_market = @from == ApplicationHelper::MARKET_NAME                     # true si el origen es el mercado
    @to_market = @to == ApplicationHelper::MARKET_NAME                         # true si el destino es el mercado

    # HTML para mostrar la transferencia en la interfaz
    @transfer_div = "
    <p class=\"text-sm #{@from_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@from}</p>
    <span class=\"mx-2 text-xl #{@from_market ? 'text-green-500' : @to_market ? 'text-red-500' : 'text-white'}\">
      #{@clause ? "&rarr;&rarr;&rarr;" : "&rarr;"}
    </span>
    <p class=\"text-sm #{@to_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@to}</p>
    "
  end

  # Función que convierte un jugador en transferencia a string
  def to_s
    target = "#{@clause ? "💰" : ""} #{@from} → #{@to}"
    if @from_market
      target = "#{"+".green} #{@to}"                                          # compra desde el mercado
    elsif @to_market
      target = "#{"-".red} #{@from}"                                          # venta al mercado
    end

    content = base_string + [ target ]
    content = content.map { |c| c.bold } if @own                              # transferencia propia en negrita
    concat(content)
  end
end
