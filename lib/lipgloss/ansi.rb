# frozen_string_literal: true

require "unicode/display_width"

module Lipgloss
  module Ansi
    # Regex to match ANSI escape sequences
    ANSI_RE = /\e\[\d*(?:;\d*)*[A-Za-z]|\e\][^\a\e]*(?:\a|\e\\)/

    # ANSI SGR codes
    RESET = "\e[0m"
    BOLD = "\e[1m"
    FAINT = "\e[2m"
    ITALIC = "\e[3m"
    UNDERLINE = "\e[4m"
    BLINK = "\e[5m"
    REVERSE = "\e[7m"
    STRIKETHROUGH = "\e[9m"

    # Remove all ANSI escape sequences from a string
    def self.strip(string)
      string.gsub(ANSI_RE, "")
    end

    # Calculate visible display width of a string (ANSI-aware, Unicode-aware)
    def self.width(string)
      lines = string.split("\n", -1)
      lines.map { |line| Unicode::DisplayWidth.of(strip(line)) }.max || 0
    end

    # Calculate height of a string (number of lines)
    def self.height(string)
      string.count("\n") + 1
    end

    # Return [width, height] of a string
    def self.size(string)
      [width(string), height(string)]
    end

    # Truncate a string to max_width visible characters, preserving ANSI escape sequences
    def self.truncate(str, max_width) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return str if width(str) <= max_width

      result = +""
      current_width = 0
      in_escape = false
      escape_buf = +""

      str.each_char do |ch|
        if in_escape
          escape_buf << ch
          if ch.match?(/[A-Za-z]/)
            result << escape_buf
            in_escape = false
            escape_buf = +""
          end
        elsif ch == "\e"
          in_escape = true
          escape_buf = +ch.dup
        else
          ch_width = Unicode::DisplayWidth.of(ch)
          break if current_width + ch_width > max_width

          result << ch
          current_width += ch_width
        end
      end

      result
    end # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # Apply ANSI SGR codes to text
    # codes is an array of ANSI escape strings like ["\e[1m", "\e[38;2;255;0;0m"]
    def self.apply(text, codes)
      return text if codes.empty? || text.empty?

      "#{codes.join}#{text}#{RESET}"
    end

    # Apply ANSI codes to each line of a multi-line string independently
    # This prevents style bleeding across newlines
    def self.apply_per_line(text, codes)
      return text if codes.empty?

      text.split("\n", -1).map { |line| line.empty? ? line : apply(line, codes) }.join("\n")
    end
  end
end
