# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  # Position constants for alignment
  #
  # Positions are represented as floats from 0.0 to 1.0:
  # - 0.0 = top/left
  # - 0.5 = center
  # - 1.0 = bottom/right
  module Position
    # Top alignment (0.0)
    TOP = 0.0

    # Bottom alignment (1.0)
    BOTTOM = 1.0

    # Left alignment (0.0)
    LEFT = 0.0

    # Right alignment (1.0)
    RIGHT = 1.0

    # Center alignment (0.5)
    CENTER = 0.5

    SYMBOLS = {
      top: TOP,
      bottom: BOTTOM,
      left: LEFT,
      right: RIGHT,
      center: CENTER
    }.freeze

    def self.resolve(value)
      case value
      when Symbol then SYMBOLS.fetch(value) { raise ArgumentError, "Unknown position: #{value.inspect}" }
      when String then SYMBOLS.fetch(value.to_sym) { raise ArgumentError, "Unknown position: #{value.inspect}" }
      when Numeric then value.to_f
      else raise ArgumentError, "Position must be a Symbol or Numeric, got #{value.class}"
      end
    end
  end
end
