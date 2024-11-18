require "colorize"

module ApplicationHelper
  # Constants
  MARKET_NAME = "Fantasy MARCA"
  SEPARATOR = " | ".grey
  UNKNOWN = "UNKNOWN"

  def parse_status(original)
    case original
    when "injury"
      "+".red.bold
    when "doubt"
      "?".yellow.bold
    when "red"
      "◼".red.bold
    else
      ""
    end
  end

  def parse_trend(original)
    case original
    when "↑"
      "↑".green
    when "↓"
      "↓".red
    else
      "~".yellow
    end
  end

  def max(key, value = nil)
    return @MAXES[key] if value.nil?

    @MAXES ||= {}
    length = value.to_s.length
    @MAXES[key] = length if @MAXES[key].nil? || length > @MAXES[key]
  end

  # Helper methods
  def format_num(num)
    return "-" if num.nil?
    num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  end

  def concat(arr)
    arr.compact.join(SEPARATOR)
  end
end
