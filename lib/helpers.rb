require 'curses'

def format_num(num)
  # formato español, separador de miles con punto y separador de decimales con coma
  num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse + '€'
end

def status(original)
  case original
  when 'injury'
    '+'
  when 'doubt'
    '?'
  when 'red'
    '◼'
  else
    ''
  end
end

def trend(original)
  case original
  when '↑'
    '↑ '
  when '↓'
    '↓ '
  else
    '~ '
  end
end

module Helpers
  def self.center_text(text)
    width = Curses.cols
    height = Curses.lines
    start_x = (width - text.length) / 2
    start_y = height / 2

    Curses.setpos(start_y, start_x)
    Curses.addstr(text)
  end

  def self.init_colors
    Curses.start_color
    Curses.init_pair(Curses::COLOR_RED, Curses::COLOR_RED, Curses::COLOR_BLACK)
    Curses.init_pair(Curses::COLOR_GREEN, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
    Curses.init_pair(Curses::COLOR_YELLOW, Curses::COLOR_YELLOW, Curses::COLOR_BLACK)
    Curses.init_pair(Curses::COLOR_BLUE, Curses::COLOR_BLUE, Curses::COLOR_BLACK)
    Curses.init_pair(Curses::COLOR_MAGENTA, Curses::COLOR_MAGENTA, Curses::COLOR_BLACK)
    Curses.init_pair(Curses::COLOR_CYAN, Curses::COLOR_CYAN, Curses::COLOR_BLACK)
    Curses.init_pair(Curses::COLOR_WHITE, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
  end

  def self.colored_string(str, color_pair)
    Curses.attron(color_pair) { str }
  end

  def self.display_debug(data)
    Curses.setpos(Curses.lines - 1, 0)
    Curses.clrtoeol
    Curses.addstr(data)
  end

  def self.wipe_screen
    Curses.clear
    (0..Curses.lines).each do |line|
      Curses.setpos(line, 0)
      Curses.clrtoeol
    end
  end
end
