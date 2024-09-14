require 'colorize'

$SEPARATOR = ' | '.grey

def format_num(num)
  # formato español, separador de miles con punto y separador de decimales con coma
  num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse + '€'
end

def status(original)
  case original
  when 'injury'
    '+'.red.bold
  when 'doubt'
    '?'.yellow.bold
  when 'red'
    '◼'.red.bold
  else
    ''
  end
end

def concat(array)
  array.join($SEPARATOR)
end
