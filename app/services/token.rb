require "dotenv/load"

class Token
  attr_accessor :value

  def initialize(name = "TOKEN", mandatory = true)
    @value = ENV[name]

    if @value.nil? && mandatory then
      puts "#{name}: "
      @value = gets.chomp
    end

    validate_structure if mandatory
  end

  def validate_structure
    if @value.nil? || @value.empty? then
      raise "Token is empty"
    end
  end
end
