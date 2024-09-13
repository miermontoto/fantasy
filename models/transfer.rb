require_relative 'position'

$MARKET_NAME = 'Fantasy MARCA'

class Transfer
  attr_accessor :player, :position, :from, :to, :price

  def initialize(info)
    @player = info[:player]
    @position = Position.new(info[:position])
    @from = info[:from]
    @to = info[:to]
    @price = format_num(info[:price]) + '€'
    @own = info[:user] == @to || info[:user] == @from
  end

  def to_s
    target = "(#{@from} → #{@to})"
    if @from == $MARKET_NAME then
      target = "(#{"+".green} #{@to})"
    elsif @to == $MARKET_NAME then
      target = "(#{"-".red} #{@from})"
    end
    string = "#{@position.to_s} #{@player.ljust(18)} #{@price.ljust(12)} #{target}"

    if @own then
      string = string.bold
    end

    string
  end
end
