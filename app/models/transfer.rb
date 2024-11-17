class Transfer
  include ApplicationHelper

  attr_reader :player, :position, :from, :to, :price, :date, :status, :user
  attr_reader :player_img, :transfer_div, :team_logo, :points

  def initialize(attributes = {})
    @player = attributes[:player]
    @position = Position.new(attributes[:position])
    @from = attributes[:from]
    @to = attributes[:to]
    @price = attributes[:price]
    @date = attributes[:date]
    @status = attributes[:status]
    @user = attributes[:user]
    @player_img = attributes[:player_img]
    # @variation = ((@price.to_f / @player.price.to_f) - 1) * 100

    from_market = @from == ApplicationHelper::MARKET_NAME
    to_market = @to == ApplicationHelper::MARKET_NAME

    @transfer_div = "
    <p class=\"text-sm #{from_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@from}</p>
    <span class=\"mx-2 text-lg #{from_market ? 'text-green-500' : to_market ? 'text-red-500' : 'text-white'}\">&rarr;</span>
    <p class=\"text-sm #{to_market ? 'text-gray-500 italic' : 'text-gray-200'}\">#{@to}</p>
    "

    ApplicationHelper.transfer_name_length = @player.length if @player.length > ApplicationHelper.transfer_name_length
    ApplicationHelper.transfer_price_length = @price.length if @price.length > ApplicationHelper.transfer_price_length
  end

  def to_s
    [
      @position.terminal,
      @player.ljust(ApplicationHelper.transfer_name_length),
      @from == @user ? @to : @from,
      @price.rjust(ApplicationHelper.transfer_price_length),
      @date,
      @status
    ].compact.join(SEPARATOR)
  end
end
