# frozen_string_literal: true
# rbs_inline: enabled

require_relative "lipgloss/version"
require_relative "lipgloss/lipgloss"
require_relative "lipgloss/position"
require_relative "lipgloss/border"
require_relative "lipgloss/color"
require_relative "lipgloss/table"

module Lipgloss
  TOP = Position::TOP #: Float
  BOTTOM = Position::BOTTOM #: Float
  LEFT = Position::LEFT #: Float
  RIGHT = Position::RIGHT #: Float
  CENTER = Position::CENTER #: Float

  NORMAL_BORDER = Border::NORMAL #: Symbol
  ROUNDED_BORDER = Border::ROUNDED #: Symbol
  THICK_BORDER = Border::THICK #: Symbol
  DOUBLE_BORDER = Border::DOUBLE #: Symbol
  HIDDEN_BORDER = Border::HIDDEN #: Symbol
  BLOCK_BORDER = Border::BLOCK #: Symbol
  ASCII_BORDER = Border::ASCII #: Symbol

  NO_TAB_CONVERSION = -1 #: Integer
end
