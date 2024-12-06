class Event
  include ApplicationHelper

  attr_reader :type, :date, :raw_date, :data

  def initialize(attributes = {})
    @type = attributes[:type]
    @date = attributes[:date]
    @raw_date = attributes[:raw_date]
    @data = attributes[:data]
  end

  def to_s
    case @type
    when :gameweek_start
      "#{@raw_date} - #{@data[:gameweek]} #{@data[:subtitle]}"
    when :gameweek_end
      gameweek_end_to_s
    when :clause_drops
      clause_drops_to_s
    when :transfer
      transfer_to_s
    else
      "Unknown event type: #{@type}"
    end
  end

  private

  def gameweek_end_to_s
    result = "#{@raw_date} - Fin de #{@data[:gameweek]}\n"
    @data[:rankings].each do |user|
      result += "  #{user[:position]}. #{user[:name]} - #{user[:points]}pts (#{user[:profit]})\n"
    end
    result.chomp
  end

  def clause_drops_to_s
    result = "#{@raw_date} - Bajadas de cláusulas\n"
    @data[:players].each do |player|
      result += "  #{player[:name]} (#{player[:owner]}) - #{player[:new_price]} ← #{player[:old_price]}\n"
    end
    result.chomp
  end

  def transfer_to_s
    @data.to_s
  end
end
