require "colorize"

$BROWSER_POSTIIONS = {
  "pos-1" => { position: "PT", color: "bg-yellow-300" },
  "pos-2" => { position: "DF", color: "bg-cyan-400" },
  "pos-3" => { position: "MC", color: "bg-green-400" },
  "pos-4" => { position: "DL", color: "bg-red-400" }
}

$TERMINAL_POSTIIONS = {
  "pos-1" => "[PT]".yellow,
  "pos-2" => "[DF]".cyan,
  "pos-3" => "[MC]".green,
  "pos-4" => "[DL]".red
}

class Position
  attr_reader :browser, :terminal

  def initialize(str)
    @browser = $BROWSER_POSTIIONS[str]
    @terminal = $TERMINAL_POSTIIONS[str]
  end

  def to_s
    @terminal
  end

  def to_i
    $TERMINAL_POSTIIONS.key(@terminal).split("-").last.to_i
  end
end
