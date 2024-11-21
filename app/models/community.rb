class Community
  include ApplicationHelper

  attr_reader :id, :name, :icon, :balance, :offers

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name] || ""
    @icon = attributes[:icon] || ""
    @balance = attributes[:balance] || 0
    @offers = attributes[:offers] || 0

    @balance_string = format_num(balance) + "€"

    max("name", @name)
    max("balance", @balance_string)
  end

  def to_s
    justed_balance = @balance_string.rjust(max("balance"))
    content = [
      id.to_s.gray,
      name.ljust(max("name")).bold,
      @balance.negative? ? justed_balance.red : justed_balance,
      @offers.positive? ? "ofertas: #{@offers}".yellow : "",
    ]

    concat(content)
  end
end
