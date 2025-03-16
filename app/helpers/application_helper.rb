require "colorize"

module ApplicationHelper
  # Constants
  MARKET_NAME = "Fantasy MARCA"
  SEPARATOR = " | ".grey
  UNKNOWN = "UNKNOWN"
  SELLING_TEXT = "En venta"
  FREE_AGENT = "Libre"

  # Devuelve el símbolo de la tendencia de diferencia de un valor
  # Los rangos que ofrece el mercado van entre -5% y 5%
  # Si el valor es negativo, en general es malo.
  # Si el valor es positivo, en general es bueno.
  # Si el valor es 5% o superior, es excelente.
  def parse_difference_trend(percentage)
    if percentage.nil? || percentage == 0 then; return "~".yellow; end
    if percentage.negative? then; return "↓".red; end
    if percentage < 5 then; return "↑".green; end
    "↑↑".green
  end

  # Helper methods
  def format_num(num)
    return "-" if num.nil?
    num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  end

  def format_value(num)
    "€ " + format_num(num)
  end

  def concat(arr)
    arr.compact.join(SEPARATOR)
  end

  # Función que calcula la longitud máxima de un atributo
  def max(key, value = nil)
    return (@@MAXES[key] || 0) if value.nil?

    @@MAXES ||= {}
    length = value.to_s.length
    @@MAXES[key] = length if @@MAXES[key].nil? || length > @@MAXES[key]
  end
end
