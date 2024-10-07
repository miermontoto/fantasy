require_relative 'base_view'

class FeedView < BaseView
  def initialize
    super('feed', Curses::COLOR_GREEN)
  end
end
