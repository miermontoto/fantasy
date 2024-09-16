require 'dotenv/load'

class Token
  attr_accessor :value

  def initialize(name = 'TOKEN')
    @value = ENV[name]

    if @value.nil? then
      puts "#{name}: "
      @value = gets.chomp
    end

    validate_structure
  end

  def validate_structure
    if @value.nil? || @value.empty? then
      raise 'Token is empty'
    end
  end
end
