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

  class Text
    class << self
      def default
        "\033[39m"
      end

      %w(black red green yellow blue magenta cyan light_gray).each_with_index do |color, value|
        define_method("#{color}") do |*args, &block|
          "\033[#{30 + value}m#{block.call}#{default}"
        end
      end

      %w(dark_gray light_red light_green light_yellow light_blue light_magenta light_cyan white).each_with_index do |color, value|
        define_method("#{color}") do |*args, &block|
          "\033[#{90 + value}m#{block.call}#{default}"
        end
      end
    end
  end

  class Background
    class << self
      def default
        "\033[49m"
      end

      %w(black red green yellow blue magenta cyan light_gray).each_with_index do |color, value|
        define_method("#{color}") do |*args, &block|
          "\033[#{40 + value}m#{block.call}#{default}"
        end
      end

      %w(dark_gray light_red light_green light_yellow light_blue light_magenta light_cyan white).each_with_index do |color, value|
        define_method("#{color}") do |*args, &block|
          "\033[#{100 + value}m#{block.call}#{default}"
        end
      end
    end
  end

  class Formatting
    class << self
      def default
        "\033[0m"
      end
      %w(bold dim underline blink reverse hidden).each_with_index do |color, value|
        define_method("#{color}") do |*args, &block|
          "\033[#{1 + value}m#{block.call}\033[#{21 + value}m"
        end
      end

    end
  end
end
