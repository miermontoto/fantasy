class Transfer
  include ApplicationHelper

  attr_accessor :player, :position, :from, :to, :price, :date, :status, :user

  def initialize(attributes = {})
    @player = attributes[:player]
    @position = Position.new(attributes[:position])
    @from = attributes[:from]
    @to = attributes[:to]
    @price = attributes[:price]
    @date = attributes[:date]
    @status = attributes[:status]
    @user = attributes[:user]

    ApplicationHelper.transfer_name_length = @player.length if @player.length > ApplicationHelper.transfer_name_length
    ApplicationHelper.transfer_price_length = @price.length if @price.length > ApplicationHelper.transfer_price_length
  end

  def to_s
    [
      @position,
      @player.ljust(ApplicationHelper.transfer_name_length),
      @from == @user ? @to : @from,
      @price.rjust(ApplicationHelper.transfer_price_length),
      @date,
      @status
    ].compact.join(SEPARATOR)
  end
end
