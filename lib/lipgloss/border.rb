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

    # Markdown border
    MARKDOWN = :markdown

    # Border character definitions
    # Each border type is a frozen hash with keys:
    # :top, :bottom, :left, :right,
    # :top_left, :top_right, :bottom_left, :bottom_right,
    # :middle_left, :middle_right, :middle, :middle_top, :middle_bottom
    CHARS = {
      normal: {
        top: "─", bottom: "─", left: "│", right: "│",
        top_left: "┌", top_right: "┐", bottom_left: "└", bottom_right: "┘",
        middle_left: "├", middle_right: "┤", middle: "┼",
        middle_top: "┬", middle_bottom: "┴"
      }.freeze,
      rounded: {
        top: "─", bottom: "─", left: "│", right: "│",
        top_left: "╭", top_right: "╮", bottom_left: "╰", bottom_right: "╯",
        middle_left: "├", middle_right: "┤", middle: "┼",
        middle_top: "┬", middle_bottom: "┴"
      }.freeze,
      thick: {
        top: "━", bottom: "━", left: "┃", right: "┃",
        top_left: "┏", top_right: "┓", bottom_left: "┗", bottom_right: "┛",
        middle_left: "┣", middle_right: "┫", middle: "╋",
        middle_top: "┳", middle_bottom: "┻"
      }.freeze,
      double: {
        top: "═", bottom: "═", left: "║", right: "║",
        top_left: "╔", top_right: "╗", bottom_left: "╚", bottom_right: "╝",
        middle_left: "╠", middle_right: "╣", middle: "╬",
        middle_top: "╦", middle_bottom: "╩"
      }.freeze,
      hidden: {
        top: " ", bottom: " ", left: " ", right: " ",
        top_left: " ", top_right: " ", bottom_left: " ", bottom_right: " ",
        middle_left: " ", middle_right: " ", middle: " ",
        middle_top: " ", middle_bottom: " "
      }.freeze,
      block: {
        top: "█", bottom: "█", left: "█", right: "█",
        top_left: "█", top_right: "█", bottom_left: "█", bottom_right: "█",
        middle_left: "█", middle_right: "█", middle: "█",
        middle_top: "█", middle_bottom: "█"
      }.freeze,
      outer_half_block: {
        top: "▀", bottom: "▄", left: "▌", right: "▐",
        top_left: "▛", top_right: "▜", bottom_left: "▙", bottom_right: "▟",
        middle_left: "▌", middle_right: "▐", middle: " ",
        middle_top: "▀", middle_bottom: "▄"
      }.freeze,
      inner_half_block: {
        top: "▄", bottom: "▀", left: "▐", right: "▌",
        top_left: "▗", top_right: "▖", bottom_left: "▝", bottom_right: "▘",
        middle_left: "▐", middle_right: "▌", middle: " ",
        middle_top: "▄", middle_bottom: "▀"
      }.freeze,
      ascii: {
        top: "-", bottom: "-", left: "|", right: "|",
        top_left: "+", top_right: "+", bottom_left: "+", bottom_right: "+",
        middle_left: "+", middle_right: "+", middle: "+",
        middle_top: "+", middle_bottom: "+"
      }.freeze,
      markdown: {
        top: "-", bottom: "-", left: "|", right: "|",
        top_left: "|", top_right: "|", bottom_left: "|", bottom_right: "|",
        middle_left: "|", middle_right: "|", middle: "|",
        middle_top: "|", middle_bottom: "|"
      }.freeze
    }.freeze

    # Get border characters for a border type
    # Accepts a symbol (:rounded, :normal, etc.) or a custom hash
    def self.chars_for(border_type)
      if border_type.is_a?(Hash)
        border_type
      else
        CHARS.fetch(border_type, CHARS[:rounded])
      end
    end
  end
end
