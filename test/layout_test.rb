# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class LayoutTest < Minitest::Spec
    it "joins strings horizontally" do
      result = Lipgloss.join_horizontal(:top, "Left", "Right")
      assert_equal "LeftRight", result
    end

    it "joins strings vertically" do
      result = Lipgloss.join_vertical(:left, "Top", "Bottom")
      assert_equal "Top   \nBottom", result
    end

    it "joins multiple strings with varargs" do
      result = Lipgloss.join_horizontal(:top, "A", "B", "C", "D")
      assert_equal "ABCD", result
    end

    it "joins splatted array" do
      items = ["X", "Y", "Z"]
      result = Lipgloss.join_horizontal(:top, *items)
      assert_equal "XYZ", result
    end

    it "calculates width" do
      text = "Hello"
      assert_equal 5, Lipgloss.width(text)
    end

    it "calculates height" do
      text = "Line 1\nLine 2\nLine 3"
      assert_equal 3, Lipgloss.height(text)
    end

    it "calculates size" do
      text = "Hello\nWorld"
      width, height = Lipgloss.size(text)
      assert_equal 5, width
      assert_equal 2, height
    end

    it "places text at position" do
      result = Lipgloss.place(5, 3, :center, :center, "X")
      assert_equal "     \n  X  \n     ", result
    end

    it "places text horizontally" do
      result = Lipgloss.place_horizontal(10, :center, "X")
      assert_equal "    X     ", result
    end

    it "places text vertically" do
      result = Lipgloss.place_vertical(5, :center, "X")
      assert_equal " \n \nX\n \n ", result
    end

    it "detects dark background" do
      result = Lipgloss.has_dark_background?
      assert [true, false].include?(result)
    end

    it "join_horizontal normalizes line widths within blocks" do
      # Block A has lines of different widths
      block_a = "Short\nLonger line"
      block_b = "X\nY"

      result = Lipgloss.join_horizontal(:top, block_a, block_b)
      lines = result.split("\n")

      # "Short" should be padded to match "Longer line" width (11)
      # so block_b starts at the same column on both lines
      assert_equal lines[0].index("X"), lines[1].index("Y"),
                   "Second block should start at the same column on all lines"
    end

    it "join_horizontal pads ragged blocks correctly" do
      block_a = "A\nBBB"
      block_b = "1\n2"

      result = Lipgloss.join_horizontal(:top, block_a, block_b)
      lines = result.split("\n")

      # Line 0: "A  1" (A padded to 3 + 1)
      # Line 1: "BBB2"
      assert_equal "A  1", lines[0]
      assert_equal "BBB2", lines[1]
    end
  end
end
