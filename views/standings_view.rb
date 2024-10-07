require_relative 'base_view'

class StandingsView < BaseView
  def initialize
    super('standings', Curses::COLOR_MAGENTA)
  end
end
