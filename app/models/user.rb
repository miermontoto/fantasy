require "colorize"

class User
  include ApplicationHelper

  attr_reader :position, :name, :players, :value, :points, :diff, :user_img,
                :played, :myself, :bench, :average, :id

  def initialize(attributes = {})
    @id = attributes[:id]
    @position = attributes[:position]
    @name = attributes[:name]
    @players = attributes[:players].to_s + " jugadores" unless attributes[:players].nil?
    @value = format_value(attributes[:value]) unless attributes[:value].nil?
    @points = attributes[:points].to_s + " puntos"
    @diff = attributes[:diff]
    @user_img = attributes[:user_img] || "https://mier.info/assets/favicon.svg"
    @played = attributes[:played] unless attributes[:played].nil?
    @myself = attributes[:myself] || false
    @average = attributes[:average]

    @bench = attributes[:bench]
    @players = @bench.size.to_s + " jugadores" if (@bench.present? && @players.nil?)
    @value = (@points.to_f / @players.split(" ").first.to_f).round(1).to_s + " avg" unless @value.present?
  end

  def to_s
    base = @position.present? ? @position.to_s.rjust(2) : ""
    base + [
      @name,
      @players,
      @value,
      @points,
      @diff
    ].compact.join(SEPARATOR)
  end
end
