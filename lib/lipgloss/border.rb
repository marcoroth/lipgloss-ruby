# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  module Border
    # Standard border with normal weight and 90 degree corners
    #   ┌───┐
    #   │   │
    #   └───┘
    NORMAL = :normal

    # Border with rounded corners
    #   ╭───╮
    #   │   │
    #   ╰───╯
    ROUNDED = :rounded

    # Thicker border
    #   ┏━━━┓
    #   ┃   ┃
    #   ┗━━━┛
    THICK = :thick

    # Double-line border
    #   ╔═══╗
    #   ║   ║
    #   ╚═══╝
    DOUBLE = :double

    # ASCII border (compatible with all terminals)
    #   +---+
    #   |   |
    #   +---+
    ASCII = :ascii

    # Hidden border (spaces, maintains layout)
    HIDDEN = :hidden

    # Block border (full blocks)
    #   ████
    #   █  █
    #   ████
    BLOCK = :block

    OUTER_HALF_BLOCK = :outer_half_block
    INNER_HALF_BLOCK = :inner_half_block
  end
end
