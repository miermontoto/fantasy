require 'curses'
require_relative 'lib/helpers'
require_relative 'views/team_view'
require_relative 'views/feed_view'
require_relative 'views/market_view'
require_relative 'views/standings_view'

Curses.init_screen
Curses.start_color
Curses.curs_set(0)
Curses.noecho
Curses.cbreak

Curses.init_pair(Curses::COLOR_BLUE, Curses::COLOR_BLUE, Curses::COLOR_BLACK)
Curses.init_pair(Curses::COLOR_GREEN, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
Curses.init_pair(Curses::COLOR_YELLOW, Curses::COLOR_YELLOW, Curses::COLOR_BLACK)
Curses.init_pair(Curses::COLOR_MAGENTA, Curses::COLOR_MAGENTA, Curses::COLOR_BLACK)
Curses.init_pair(Curses::COLOR_RED, Curses::COLOR_RED, Curses::COLOR_BLACK)
Curses.init_pair(Curses::COLOR_WHITE, Curses::COLOR_WHITE, Curses::COLOR_BLACK)

views = {
  'f' => FeedView.new,
  't' => TeamView.new,
  'm' => MarketView.new,
  's' => StandingsView.new
}

current_view = views['f']
current_view.display

loop do
  input = Curses.getch

  case input
  when 't', 'f', 'm', 's'
    current_view = views[input]
    current_view.display
  when 'r'
    current_view.display
  when 'j'
    # TODO: guardar a JSON en raíz
  when 'q'
    break
  end
end

Curses.close_screen
