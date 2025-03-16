require "colorize"

$BROWSER_TRENDS = {
  "↑" => { symbol: "+", color: "bg-red-500", text_color: "text-white" },
  "↓" => { symbol: "?", color: "bg-yellow-500", text_color: "text-black" },
  "~" => { symbol: "", color: "bg-red-500", text_color: "text-white" },
}

$TERMINAL_TRENDS = {
  "↑" => "↑".green.bold,
  "↓" => "↓".red.bold,
  "~" => "~".yellow.bold
}

class Trend
  attr_reader :browser, :terminal, :value

  # puede ser, o un símbolo de trend válido, o un trend en sí, nil, o un número
  def initialize(mixed)
    # si es nil, el trend es neutro
    if mixed.nil?
      @browser = $BROWSER_TRENDS["~"]
      @terminal = $TERMINAL_TRENDS["~"]
      return
    end

    # si es uno de los símbolos válidos, se aplica el estilo
    if $BROWSER_TRENDS[mixed].present?
      @browser = $BROWSER_TRENDS[mixed]
      @terminal = $TERMINAL_TRENDS[mixed]
      return
    end

    # si es un número, se aplica el estilo según el signo
    if mixed.is_a?(Integer)
      @browser = $BROWSER_TRENDS[mixed > 0 ? "↑" : "↓"]
      @terminal = $TERMINAL_TRENDS[mixed > 0 ? "↑" : "↓"]
      @value = mixed # solo si es un número, se guarda el valor
      return
    end

    # si no es nada de lo anterior, neutro
    @browser = $BROWSER_TRENDS["~"]
    @terminal = $TERMINAL_TRENDS["~"]
  end

  def to_s
    @terminal || ""
  end

  def present?
    !@terminal.nil?
  end

  def neutral?
    @terminal == $TERMINAL_TRENDS["~"]
  end

  def positive?
    @terminal == $TERMINAL_TRENDS["↑"]
  end

  def negative?
    @terminal == $TERMINAL_TRENDS["↓"]
  end
end
