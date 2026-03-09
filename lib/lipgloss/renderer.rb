# frozen_string_literal: true

module Lipgloss
  class << self
    def _join_horizontal(position, strings) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      return "" if strings.empty?
      return strings.first if strings.length == 1

      # Split each string into lines
      blocks = strings.map { |s| s.split("\n", -1) }
      max_height = blocks.map(&:length).max

      # Normalize line widths within each block, then pad to max_height
      blocks = blocks.map do |lines|
        content_width = lines.map { |l| Ansi.width(l) }.max || 0
        # Pad each line to the block's max width
        lines = lines.map do |l|
          lw = Ansi.width(l)
          lw < content_width ? l + (" " * (content_width - lw)) : l
        end
        if lines.length < max_height
          gap = max_height - lines.length
          top = (gap * position).floor
          bottom = gap - top
          blank = " " * content_width
          Array.new(top, blank) + lines + Array.new(bottom, blank)
        else
          lines
        end
      end

      # Concatenate corresponding lines
      (0...max_height).map do |i|
        blocks.map { |lines| lines[i] || "" }.join
      end.join("\n")
    end # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def _join_vertical(position, strings) # rubocop:disable Metrics/AbcSize
      return "" if strings.empty?

      # Split all strings into lines
      all_lines = strings.flat_map { |s| s.split("\n", -1) }
      max_width = all_lines.map { |l| Ansi.width(l) }.max || 0

      # Pad each line to max_width based on position
      all_lines.map do |line|
        line_width = Ansi.width(line)
        if line_width < max_width
          gap = max_width - line_width
          left = (gap * position).floor
          right = gap - left
          (" " * left) + line + (" " * right)
        else
          line
        end
      end.join("\n")
    end # rubocop:enable Metrics/AbcSize

    def width(string)
      Ansi.width(string)
    end

    def height(string)
      Ansi.height(string)
    end

    def size(string)
      Ansi.size(string)
    end

    def _place(width, height, horizontal, vertical, string, **_opts)
      str = _place_horizontal(width, horizontal, string)
      _place_vertical(height, vertical, str)
    end

    def _place_horizontal(width, position, string)
      lines = string.split("\n", -1)
      lines.map do |line|
        line_width = Ansi.width(line)
        if line_width >= width
          line
        else
          gap = width - line_width
          left = (gap * position).floor
          right = gap - left
          (" " * left) + line + (" " * right)
        end
      end.join("\n")
    end

    def _place_vertical(height, position, string) # rubocop:disable Metrics/AbcSize
      lines = string.split("\n", -1)
      return lines.join("\n") if lines.length >= height

      content_width = lines.map { |l| Ansi.width(l) }.max || 0
      gap = height - lines.length
      top = (gap * position).floor
      bottom = gap - top
      blank = " " * content_width
      (Array.new(top, blank) + lines + Array.new(bottom, blank)).join("\n")
    end # rubocop:enable Metrics/AbcSize

    def has_dark_background? # rubocop:disable Naming/PredicatePrefix
      Color.has_dark_background?
    end # rubocop:enable Naming/PredicatePrefix

    def version
      VERSION
    end
  end
end
