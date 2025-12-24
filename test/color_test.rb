# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class ColorTest < Minitest::Spec
    describe "ANSIColor.resolve" do
      it "resolves basic color symbols" do
        assert_equal "0", ANSIColor.resolve(:black)
        assert_equal "1", ANSIColor.resolve(:red)
        assert_equal "2", ANSIColor.resolve(:green)
        assert_equal "3", ANSIColor.resolve(:yellow)
        assert_equal "4", ANSIColor.resolve(:blue)
        assert_equal "5", ANSIColor.resolve(:magenta)
        assert_equal "6", ANSIColor.resolve(:cyan)
        assert_equal "7", ANSIColor.resolve(:white)
      end

      it "resolves bright color symbols" do
        assert_equal "8", ANSIColor.resolve(:bright_black)
        assert_equal "9", ANSIColor.resolve(:bright_red)
        assert_equal "10", ANSIColor.resolve(:bright_green)
        assert_equal "11", ANSIColor.resolve(:bright_yellow)
        assert_equal "12", ANSIColor.resolve(:bright_blue)
        assert_equal "13", ANSIColor.resolve(:bright_magenta)
        assert_equal "14", ANSIColor.resolve(:bright_cyan)
        assert_equal "15", ANSIColor.resolve(:bright_white)
      end

      it "passes through strings" do
        assert_equal "196", ANSIColor.resolve("196")
        assert_equal "21", ANSIColor.resolve("21")
      end

      it "converts integers to strings" do
        assert_equal "196", ANSIColor.resolve(196)
        assert_equal "0", ANSIColor.resolve(0)
        assert_equal "255", ANSIColor.resolve(255)
      end

      it "raises for unknown symbols" do
        assert_raises(ArgumentError) { ANSIColor.resolve(:unknown) }
        assert_raises(ArgumentError) { ANSIColor.resolve(:pink) }
      end

      it "raises for invalid types" do
        assert_raises(ArgumentError) { ANSIColor.resolve([]) }
        assert_raises(ArgumentError) { ANSIColor.resolve({}) }
      end
    end

    describe "CompleteColor" do
      it "accepts symbol for ansi" do
        color = CompleteColor.new(true_color: "#FF0000", ansi256: 196, ansi: :red)
        assert_equal "#FF0000", color.true_color
        assert_equal "196", color.ansi256
        assert_equal "1", color.ansi
      end

      it "accepts symbol for ansi256" do
        color = CompleteColor.new(true_color: "#0000FF", ansi256: :blue, ansi: :blue)
        assert_equal "4", color.ansi256
        assert_equal "4", color.ansi
      end

      it "accepts integers" do
        color = CompleteColor.new(true_color: "#00FF00", ansi256: 46, ansi: 2)
        assert_equal "46", color.ansi256
        assert_equal "2", color.ansi
      end

      it "accepts strings" do
        color = CompleteColor.new(true_color: "#FFFFFF", ansi256: "255", ansi: "15")
        assert_equal "255", color.ansi256
        assert_equal "15", color.ansi
      end

      it "returns correct hash" do
        color = CompleteColor.new(true_color: "#FF0000", ansi256: :bright_red, ansi: :red)
        expected = { true_color: "#FF0000", ansi256: "9", ansi: "1" }
        assert_equal expected, color.to_h
      end
    end

    describe "AdaptiveColor" do
      it "stores light and dark values" do
        color = AdaptiveColor.new(light: "#000000", dark: "#FFFFFF")
        assert_equal "#000000", color.light
        assert_equal "#FFFFFF", color.dark
      end

      it "returns correct hash" do
        color = AdaptiveColor.new(light: "#000", dark: "#FFF")
        assert_equal({ light: "#000", dark: "#FFF" }, color.to_h)
      end
    end

    describe "CompleteAdaptiveColor" do
      it "stores complete colors for light and dark" do
        light = CompleteColor.new(true_color: "#000", ansi256: :black, ansi: :black)
        dark = CompleteColor.new(true_color: "#FFF", ansi256: :bright_white, ansi: :bright_white)
        color = CompleteAdaptiveColor.new(light: light, dark: dark)

        assert_equal "#000", color.light.true_color
        assert_equal "#FFF", color.dark.true_color
      end

      it "returns correct nested hash" do
        light = CompleteColor.new(true_color: "#000", ansi256: 0, ansi: :black)
        dark = CompleteColor.new(true_color: "#FFF", ansi256: 15, ansi: :bright_white)
        color = CompleteAdaptiveColor.new(light: light, dark: dark)

        expected = {
          light: { true_color: "#000", ansi256: "0", ansi: "0" },
          dark: { true_color: "#FFF", ansi256: "15", ansi: "15" }
        }
        assert_equal expected, color.to_h
      end
    end

    describe "ColorBlend" do
      it "blends two colors with LUV (default)" do
        result = ColorBlend.blend("#FF0000", "#0000FF", 0.5)
        assert_match(/^#[0-9a-f]{6}$/, result)
      end

      it "blends with explicit mode" do
        luv = ColorBlend.blend("#FF0000", "#00FF00", 0.5, mode: :luv)
        rgb = ColorBlend.blend("#FF0000", "#00FF00", 0.5, mode: :rgb)
        refute_equal luv, rgb
      end

      it "generates color array with blends" do
        colors = ColorBlend.blends("#FF0000", "#0000FF", 5)
        assert_equal 5, colors.length
        assert(colors.all? { |c| c.match?(/^#[0-9a-f]{6}$/) })
      end

      it "generates 2D color grid" do
        grid = ColorBlend.grid("#FF0000", "#00FF00", "#0000FF", "#FFFF00", 3, 2)
        assert_equal 2, grid.length
        assert_equal 3, grid[0].length
        assert(grid.flatten.all? { |c| c.match?(/^#[0-9a-f]{6}$/) })
      end
    end
  end
end
