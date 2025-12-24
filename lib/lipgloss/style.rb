# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  class Style
    # @rbs *positions: Position::position_value
    # @rbs return: Style
    def align(*positions)
      _align(*positions.map { |p| Position.resolve(p) })
    end

    # @rbs position: Position::position_value
    # @rbs return: Style
    def align_horizontal(position)
      _align_horizontal(Position.resolve(position))
    end

    # @rbs position: Position::position_value
    # @rbs return: Style
    def align_vertical(position)
      _align_vertical(Position.resolve(position))
    end
  end
end
