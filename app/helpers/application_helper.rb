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

  # Devuelve el símbolo de la tendencia de aumento de un valor
  # La diferencia de valor se mide en euros.
  # Si el valor es inferior a -250.000€, es muy malo.
  # Si el valor es negativo, es malo.
  # Si el valor es 0, es neutro.
  # Si el valor es inferior a 200.000€, es bueno.
  # Si el valor es inferior a 500.000€, es muy bueno.
  # Si el valor es superior a 500.000€, es excelente.
  def increase_trend(value)
    if value.nil? || value == 0 then; return "~".yellow; end
    if value < -250000 then; return "↓↓".red; end
    if value < 0 then; return "↓".red; end
    if value < 200000 then; return "↑".green; end
    if value < 500000 then; return "↑↑".green; end
    "↑↑↑".green # superior a 500.000€
  end

  # Devuelve el símbolo de la tendencia de diferencia de un valor
  # Los rangos que ofrece el mercado van entre -5% y 5%
  # Si el valor es negativo, en general es malo.
  # Si el valor es positivo, en general es bueno.
  # Si el valor es 5% o superior, es excelente.
  def difference_trend(percentage)
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

  def concat(arr)
    arr.compact.join(SEPARATOR)
  end

  # Función que calcula la longitud máxima de un atributo
  def max(key, value = nil)
    return @@MAXES[key] if value.nil?

    @@MAXES ||= {}
    length = value.to_s.length
    @@MAXES[key] = length if @@MAXES[key].nil? || length > @@MAXES[key]
  end
end
