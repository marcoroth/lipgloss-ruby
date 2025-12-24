# frozen_string_literal: true

module Lipgloss
  class Style
    def align(*positions)
      _align(*positions.map { |p| Position.resolve(p) })
    end

    def align_horizontal(position)
      _align_horizontal(Position.resolve(position))
    end

    def align_vertical(position)
      _align_vertical(Position.resolve(position))
    end
  end
end
