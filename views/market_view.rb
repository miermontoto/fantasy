require_relative 'base_view'

class MarketView < BaseView
  def initialize
    super('market', Curses::COLOR_YELLOW)
  end
end
