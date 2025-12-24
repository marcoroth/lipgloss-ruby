# frozen_string_literal: true
# rbs_inline: enabled

require_relative "lipgloss/version"

begin
  major, minor, _patch = RUBY_VERSION.split(".") #: [String, String, String]
  require_relative "lipgloss/#{major}.#{minor}/lipgloss"
rescue LoadError
  require_relative "lipgloss/lipgloss"
end

require_relative "lipgloss/position"
require_relative "lipgloss/border"
require_relative "lipgloss/color"
require_relative "lipgloss/style"
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

  class << self
    # @rbs position: Position::position_value
    # @rbs *strings: String
    # @rbs return: String
    def join_horizontal(position, *strings)
      _join_horizontal(Position.resolve(position), strings)
    end

    # @rbs position: Position::position_value
    # @rbs *strings: String
    # @rbs return: String
    def join_vertical(position, *strings)
      _join_vertical(Position.resolve(position), strings)
    end

    # @rbs width: Integer
    # @rbs height: Integer
    # @rbs horizontal: Position::position_value
    # @rbs vertical: Position::position_value
    # @rbs string: String
    # @rbs return: String
    def place(width, height, horizontal, vertical, string, **)
      _place(width, height, Position.resolve(horizontal), Position.resolve(vertical), string, **)
    end

    # @rbs width: Integer
    # @rbs position: Position::position_value
    # @rbs string: String
    # @rbs return: String
    def place_horizontal(width, position, string)
      _place_horizontal(width, Position.resolve(position), string)
    end

    # @rbs height: Integer
    # @rbs position: Position::position_value
    # @rbs string: String
    # @rbs return: String
    def place_vertical(height, position, string)
      _place_vertical(height, Position.resolve(position), string)
    end
  end
end
