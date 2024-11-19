class Community
  attr_reader :id, :name, :icon, :balance, :offers

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name] || ""
    @icon = attributes[:icon] || ""
    @balance = attributes[:balance] || 0
    @offers = attributes[:offers] || 0
  end

  def to_s
    string = "#{@name}"

    if @offers.positive? then; string = "#{string} (#{@offers})".yellow; end
    if @balance.negative? then; string = string.red; end

    string
  end
end
