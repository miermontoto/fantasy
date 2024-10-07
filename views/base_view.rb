require_relative '../lib/helpers'
require_relative '../lib/browser'
require_relative '../lib/scraper'

class BaseView
  def initialize(action, color)
    @action = action
    @color = color
    @browser = Browser.new
    @scraper = Scraper.new
  end

  def display
    Helpers.wipe_screen
    Curses.setpos(0, 0)
    Curses.addstr(@action)

    begin
      html = @browser.send(@action)
      data = @scraper.send(@action, html)

      display_content(data[:data])
      display_footer_info(data[:footer_info])
    rescue StandardError => e
      display_error("failed to present view #{@action}: #{e.message}")
      raise e
    end
  end

  protected

  def add_colored_string(str, color_pair)
    Helpers.colored_string(str, color_pair)
  end

  def display_content(data)
    index = 1
    data.each do |(key, section)|
      Curses.setpos(index, 0)
      if (data.length > 1)
        Curses.addstr(section[:title])
        index += 1
      end
      section[:content].each do |item|
        Curses.setpos(index, 2)
        Curses.addstr(item.to_s)
        index += 1
      end
      index += 1
    end
  end

  def display_footer_info(footer_info)
    Curses.setpos(Curses.lines - 3, 0)
    Curses.clrtoeol
    Curses.setpos(Curses.lines - 2, 0)
    Curses.clrtoeol

    footer_info.each_with_index do |(key, info), index|
      Curses.setpos(Curses.lines - 3 + index / 2, (index % 2) * (Curses.cols / 2))
      Curses.addstr("#{info[:title]}: #{info[:data]}")
    end
  end

  def display_error(message)
    Curses.setpos(Curses.lines - 1, 0)
    add_colored_string(message, Curses.color_pair(Curses::COLOR_RED) | Curses::A_BOLD)
  end
end
