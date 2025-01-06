module FantasyHelper
  def format_num(num)
    return "-" if num.nil?
    num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  end

  def concat(arr)
    arr.join(" | ".grey)
  end
end
