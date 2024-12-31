require "colorize"

$BROWSER_STATUSES = {
  "injury" => { symbol: "+", color: "bg-red-500", text_color: "text-white" },
  "doubt" => { symbol: "?", color: "bg-yellow-500", text_color: "text-black" },
  "red" => { symbol: "◼", color: "bg-red-500", text_color: "text-white" },
  "five" => { symbol: "5", color: "bg-yellow-500", text_color: "text-red-500" }
}

$TERMINAL_STATUSES = {
  "injury" => "+".red.bold,
  "doubt" => "?".yellow.bold,
  "red" => "◼".red.bold,
  "five" => "5".red.on_yellow.bold
}

class Status
  attr_reader :browser, :terminal

  def initialize(str)
    return if str.nil? || str.empty?
    @browser = $BROWSER_STATUSES[str]
    @terminal = $TERMINAL_STATUSES[str]
  end

  def to_s
    @terminal || ""
  end

  def present?
    !@terminal.nil?
  end
end
