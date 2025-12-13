# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class LayoutTest < Minitest::Spec
    it "joins strings horizontally" do
      left = "Left"
      right = "Right"
      result = Lipgloss.join_horizontal(Lipgloss::TOP, [left, right])
      assert_equal "LeftRight", result
    end

    it "joins strings vertically" do
      top = "Top"
      bottom = "Bottom"
      result = Lipgloss.join_vertical(Lipgloss::LEFT, [top, bottom])
      assert_equal "Top   \nBottom", result
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
      text = "X"
      result = Lipgloss.place(5, 3, Lipgloss::CENTER, Lipgloss::CENTER, text)
      assert_equal "     \n  X  \n     ", result
    end

    it "places text horizontally" do
      text = "X"
      result = Lipgloss.place_horizontal(10, Lipgloss::CENTER, text)
      assert_equal "    X     ", result
    end

    it "places text vertically" do
      text = "X"
      result = Lipgloss.place_vertical(5, Lipgloss::CENTER, text)
      assert_equal " \n \nX\n \n ", result
    end

    it "detects dark background" do
      result = Lipgloss.has_dark_background?
      assert [true, false].include?(result)
    end
  end
end
