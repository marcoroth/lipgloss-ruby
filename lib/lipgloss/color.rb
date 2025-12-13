# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  # @rbs!
  #   type adaptive_color_hash = { light: String, dark: String }
  #   type complete_color_hash = { true_color: String, ansi256: String, ansi: String }
  #   type complete_adaptive_color_hash = { light: complete_color_hash, dark: complete_color_hash }

  # Adaptive color that changes based on terminal background
  #
  # @example
  #   color = Lipgloss::AdaptiveColor.new(light: "#000000", dark: "#FFFFFF")
  #   style = Lipgloss::Style.new.foreground(color)
  class AdaptiveColor
    # @rbs @light: String
    # @rbs @dark: String

    attr_reader :light #: String
    attr_reader :dark #: String

    # @rbs light: String -- color to use on light backgrounds
    # @rbs dark: String -- color to use on dark backgrounds
    # @rbs return: void
    def initialize(light:, dark:)
      @light = light
      @dark = dark
    end

    # @rbs return: adaptive_color_hash
    def to_h
      { light: @light, dark: @dark }
    end
  end

  # Complete color with explicit values for each color profile
  #
  # @example
  #   color = Lipgloss::CompleteColor.new(
  #     true_color: "#0000FF",
  #     ansi256: "21",
  #     ansi: "4"
  #   )
  class CompleteColor
    # @rbs @true_color: String
    # @rbs @ansi256: String
    # @rbs @ansi: String

    attr_reader :true_color #: String
    attr_reader :ansi256 #: String
    attr_reader :ansi #: String

    # @rbs true_color: String -- 24-bit color (e.g., "#0000FF")
    # @rbs ansi256: String -- 8-bit ANSI color (e.g., "21")
    # @rbs ansi: String -- 4-bit ANSI color (e.g., "4")
    # @rbs return: void
    def initialize(true_color:, ansi256:, ansi:)
      @true_color = true_color
      @ansi256 = ansi256
      @ansi = ansi
    end

    # @rbs return: complete_color_hash
    def to_h
      { true_color: @true_color, ansi256: @ansi256, ansi: @ansi }
    end
  end

  # Complete adaptive color with explicit values for each color profile
  # and separate options for light and dark backgrounds
  #
  # @example
  #   color = Lipgloss::CompleteAdaptiveColor.new(
  #     light: Lipgloss::CompleteColor.new(true_color: "#000", ansi256: "0", ansi: "0"),
  #     dark: Lipgloss::CompleteColor.new(true_color: "#FFF", ansi256: "15", ansi: "15")
  #   )
  class CompleteAdaptiveColor
    # @rbs @light: CompleteColor
    # @rbs @dark: CompleteColor

    attr_reader :light #: CompleteColor
    attr_reader :dark #: CompleteColor

    # @rbs light: CompleteColor -- color for light backgrounds
    # @rbs dark: CompleteColor -- color for dark backgrounds
    # @rbs return: void
    def initialize(light:, dark:)
      @light = light
      @dark = dark
    end

    # @rbs return: complete_adaptive_color_hash
    def to_h
      { light: @light.to_h, dark: @dark.to_h }
    end
  end
end
