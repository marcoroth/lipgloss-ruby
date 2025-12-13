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
  end
end
