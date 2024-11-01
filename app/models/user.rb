require 'colorize'

class User
  include ApplicationHelper

  attr_accessor :position, :name, :players, :value, :points, :diff

  def initialize(attributes = {})
    @position = attributes[:position]
    @name = attributes[:name]
    @players = attributes[:players]
    @value = attributes[:value]
    @points = attributes[:points]
    @diff = attributes[:diff]
  end

  def to_s
    [
      @position.to_s.rjust(2),
      @name,
      "#{@players} jugadores",
      "#{format_num(@value)}€",
      "#{@points} puntos",
      @diff
    ].compact.join(SEPARATOR)
  end
end
