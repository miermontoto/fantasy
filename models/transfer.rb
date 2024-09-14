require_relative 'position'

$MARKET_NAME = 'Fantasy MARCA'
$separator = ' | '.grey
$transfer_name_length = 0
$transfer_price_length = 0

class Transfer
  def initialize(info)
    @player = info[:player]
    @position = Position.new(info[:position])
    @from = info[:from]
    @to = info[:to]
    @price = format_num(info[:price])
    @own = info[:user] == @to || info[:user] == @from
    @date = info[:date]
    @status = status(info[:status])

    $transfer_name_length = @player.length if @player.length > $transfer_name_length
    $transfer_price_length = @price.length if @price.length > $transfer_price_length
  end

  def to_s
    target = "#{@from} → #{@to}"
    if @from == $MARKET_NAME then
      target = "#{"+".green} #{@to}"
    elsif @to == $MARKET_NAME then
      target = "#{"-".red} #{@from}"
    end

    info = "#{target}, #{@date}"

    content = [@position.to_s, @player.ljust($transfer_name_length), @price.ljust($transfer_price_length), info]
    if @own then # transferencia propia en negrita
      content = content.map { |c| c.bold }
    end
    concat(content)
  end
end
