# A simple class to make accessing colors in bash easy
#
# You can use it by calling the colors directly
#
# Eg:
#   puts "Hello, this is #{Bash::Text.red { "red" } }"
#       => Hello this is red
#
#   puts "Hello, this is #{Bash::Formatting.underline { "underlined" } }"
#       => Hello this is underlined
#
# You can also next them
#
#   puts "Hello, this is #{Bash::Text.red { Bash::Background.green { "red with a green background" } } }"
#       => Hello, this is red with a green background
#

class Bash

  COLOR_CODES = {
    default_text:  39,
    black:         30,
    red:           31,
    green:         32,
    yellow:        33,
    blue:          34,
    magenta:       35,
    cyan:          36,
    light_gray:    37,
    dark_gray:     90,
    light_red:     91,
    light_green:   92,
    light_yellow:  93,
    light_blue:    94,
    light_magenta: 95,
    light_cyan:    96,
    white:         97,
  }

  DEFAULTS = {
    text: 39,
    background: 49,
    formatting: 0
  }

  FORMAT_CODES = {
    bold: 1,
    dim: 2,
    underline: 4,
    blink: 5,
    reverse: 7,
    hidden: 8
  }


  class Text
    class << self
      COLOR_CODES.each do |color_name, value|
        define_method("#{color_name.to_s}") do |*args, &block|
          "\033[#{value}m#{block.call}\033[#{DEFAULTS[:text]}m"
        end
      end
    end
  end

  class Background
    class << self
      COLOR_CODES.each do |color_name, value|
        define_method("#{color_name.to_s}") do |*args, &block|
          "\033[#{value + 10}m#{block.call}\033[#{DEFAULTS[:background]}m"
        end
      end
    end
  end

  class Formatting
    class << self
      FORMAT_CODES.each do |format_name, value|
        define_method("#{format_name.to_s}") do |*args, &block|
          "\033[#{value}m#{block.call}\033[#{value + 20}m"
        end
      end
    end
  end

end
