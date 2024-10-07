require_relative 'base_view'

class TeamView < BaseView
  def initialize
    super('team', Curses::COLOR_BLUE)
  end
end
