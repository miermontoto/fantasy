require 'colorize'

module ApplicationHelper
  # Constants
  MARKET_NAME = 'Fantasy MARCA'
  SEPARATOR = ' | '.grey

  # Global variables (consider refactoring these into a state object)
  def self.max_name_length
    @max_name_length ||= 0
  end

  def self.max_name_length=(value)
    @max_name_length = value
  end

  def self.max_points_length
    @max_points_length ||= 0
  end

  def self.max_points_length=(value)
    @max_points_length = value
  end

  def self.max_average_length
    @max_average_length ||= 0
  end

  def self.max_average_length=(value)
    @max_average_length = value
  end

  def self.max_price_length
    @max_price_length ||= 0
  end

  def self.max_price_length=(value)
    @max_price_length = value
  end

  def self.transfer_name_length
    @transfer_name_length ||= 0
  end

  def self.transfer_name_length=(value)
    @transfer_name_length = value
  end

  def self.transfer_price_length
    @transfer_price_length ||= 0
  end

  def self.transfer_price_length=(value)
    @transfer_price_length = value
  end

  # Helper methods
  def format_num(num)
    return '-' if num.nil?
    num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  end

  def concat(arr)
    arr.join(SEPARATOR)
  end
end
