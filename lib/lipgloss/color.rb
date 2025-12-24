# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  # @rbs!
  #   type adaptive_color_hash = { light: String, dark: String }
  #   type complete_color_hash = { true_color: String, ansi256: String, ansi: String }
  #   type complete_adaptive_color_hash = { light: complete_color_hash, dark: complete_color_hash }

  module ANSIColor
    COLORS = {
      black: "0",
      red: "1",
      green: "2",
      yellow: "3",
      blue: "4",
      magenta: "5",
      cyan: "6",
      white: "7",
      bright_black: "8",
      bright_red: "9",
      bright_green: "10",
      bright_yellow: "11",
      bright_blue: "12",
      bright_magenta: "13",
      bright_cyan: "14",
      bright_white: "15"
    }.freeze

    def self.resolve(value)
      case value
      when Symbol then COLORS.fetch(value) { raise ArgumentError, "Unknown ANSI color: #{value.inspect}" }
      when String then value
      when Integer then value.to_s
      else raise ArgumentError, "ANSI color must be a Symbol, String, or Integer, got #{value.class}"
      end
    end
  end

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
  #     ansi256: 21,
  #     ansi: :blue
  #   )
  class CompleteColor
    # @rbs @true_color: String
    # @rbs @ansi256: String
    # @rbs @ansi: String

    attr_reader :true_color #: String
    attr_reader :ansi256 #: String
    attr_reader :ansi #: String

    # @rbs true_color: String -- 24-bit color (e.g., "#0000FF")
    # @rbs ansi256: String | Integer | Symbol -- 8-bit ANSI color (0-255, or symbol for 0-15)
    # @rbs ansi: String | Integer | Symbol -- 4-bit ANSI color (:red, :blue, etc., or 0-15)
    # @rbs return: void
    def initialize(true_color:, ansi256:, ansi:)
      @true_color = true_color
      @ansi256 = ANSIColor.resolve(ansi256)
      @ansi = ANSIColor.resolve(ansi)
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
  #     light: Lipgloss::CompleteColor.new(true_color: "#000", ansi256: :black, ansi: :black),
  #     dark: Lipgloss::CompleteColor.new(true_color: "#FFF", ansi256: :bright_white, ansi: :bright_white)
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
