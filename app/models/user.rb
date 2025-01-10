require "colorize"

class User
  include ApplicationHelper

  attr_reader :position, :name, :players, :value, :points, :diff, :user_img, :played, :myself

  def initialize(attributes = {})
    @position = attributes[:position]
    @name = attributes[:name]
    @players = attributes[:players].to_s + " jugadores"
    @value = format_value(attributes[:value]) unless attributes[:value].nil?
    @points = attributes[:points].to_s + " puntos"
    @diff = attributes[:diff]
    @user_img = attributes[:user_img] || "https://mier.info/assets/favicon.svg"
    @played = attributes[:played] unless attributes[:played].nil?
    @myself = attributes[:myself] || false
  end

  def to_s
    [
      @position.to_s.rjust(2),
      @name,
      @players,
      @value,
      @points,
      @diff
    ].compact.join(SEPARATOR)
  end
end
