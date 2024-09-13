def format_num(num)
  # formato español, separador de miles con punto y separador de decimales con coma
  num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
end
