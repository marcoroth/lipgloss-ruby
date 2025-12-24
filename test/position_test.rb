# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class PositionTest < Minitest::Spec
    describe "Position.resolve" do
      it "resolves :top to 0.0" do
        assert_equal 0.0, Position.resolve(:top)
      end

      it "resolves :bottom to 1.0" do
        assert_equal 1.0, Position.resolve(:bottom)
      end

      it "resolves :left to 0.0" do
        assert_equal 0.0, Position.resolve(:left)
      end

      it "resolves :right to 1.0" do
        assert_equal 1.0, Position.resolve(:right)
      end

      it "resolves :center to 0.5" do
        assert_equal 0.5, Position.resolve(:center)
      end

      it "resolves string 'center' to 0.5" do
        assert_equal 0.5, Position.resolve("center")
      end

      it "passes through numeric values" do
        assert_equal 0.0, Position.resolve(0)
        assert_equal 0.5, Position.resolve(0.5)
        assert_equal 1.0, Position.resolve(1)
        assert_equal 0.25, Position.resolve(0.25)
      end

      it "raises ArgumentError for unknown symbols" do
        assert_raises(ArgumentError) { Position.resolve(:unknown) }
      end

      it "raises ArgumentError for invalid types" do
        assert_raises(ArgumentError) { Position.resolve([]) }
      end
    end

    describe "join_horizontal with symbols" do
      it "accepts :top symbol" do
        result = Lipgloss.join_horizontal(:top, "A", "B")
        assert_equal "AB", result
      end

      it "accepts :bottom symbol" do
        result = Lipgloss.join_horizontal(:bottom, "A", "B")
        assert_equal "AB", result
      end

      it "accepts :center symbol" do
        result = Lipgloss.join_horizontal(:center, "A", "B")
        assert_equal "AB", result
      end

      it "accepts numeric values" do
        result = Lipgloss.join_horizontal(0.5, "A", "B")
        assert_equal "AB", result
      end

      it "accepts varargs" do
        result = Lipgloss.join_horizontal(:top, "A", "B", "C")
        assert_equal "ABC", result
      end
    end

    describe "join_vertical with symbols" do
      it "accepts :left symbol" do
        result = Lipgloss.join_vertical(:left, "A", "B")
        assert_equal "A\nB", result
      end

      it "accepts :right symbol" do
        result = Lipgloss.join_vertical(:right, "A", "B")
        assert_equal "A\nB", result
      end

      it "accepts :center symbol" do
        result = Lipgloss.join_vertical(:center, "A", "B")
        assert_equal "A\nB", result
      end

      it "accepts varargs" do
        result = Lipgloss.join_vertical(:left, "A", "B", "C")
        assert_equal "A\nB\nC", result
      end
    end

    describe "place with symbols" do
      it "accepts symbol positions" do
        result = Lipgloss.place(5, 3, :center, :center, "X")
        assert_equal "     \n  X  \n     ", result
      end

      it "accepts :left and :top" do
        result = Lipgloss.place(3, 2, :left, :top, "X")
        assert_equal "X  \n   ", result
      end

      it "accepts :right and :bottom" do
        result = Lipgloss.place(3, 2, :right, :bottom, "X")
        assert_equal "   \n  X", result
      end
    end

    describe "place_horizontal with symbols" do
      it "accepts :center symbol" do
        result = Lipgloss.place_horizontal(5, :center, "X")
        assert_equal "  X  ", result
      end

      it "accepts :left symbol" do
        result = Lipgloss.place_horizontal(5, :left, "X")
        assert_equal "X    ", result
      end

      it "accepts :right symbol" do
        result = Lipgloss.place_horizontal(5, :right, "X")
        assert_equal "    X", result
      end
    end

    describe "place_vertical with symbols" do
      it "accepts :center symbol" do
        result = Lipgloss.place_vertical(3, :center, "X")
        assert_equal " \nX\n ", result
      end

      it "accepts :top symbol" do
        result = Lipgloss.place_vertical(3, :top, "X")
        assert_equal "X\n \n ", result
      end

      it "accepts :bottom symbol" do
        result = Lipgloss.place_vertical(3, :bottom, "X")
        assert_equal " \n \nX", result
      end
    end

    describe "Style#align_horizontal with symbols" do
      it "accepts :center symbol" do
        style = Style.new.width(5).align_horizontal(:center)
        result = style.render("X")
        assert_equal "  X  ", strip_ansi(result)
      end

      it "accepts :left symbol" do
        style = Style.new.width(5).align_horizontal(:left)
        result = style.render("X")
        assert_equal "X    ", strip_ansi(result)
      end

      it "accepts :right symbol" do
        style = Style.new.width(5).align_horizontal(:right)
        result = style.render("X")
        assert_equal "    X", strip_ansi(result)
      end
    end

    describe "Style#align_vertical with symbols" do
      it "accepts :center symbol" do
        style = Style.new.height(3).align_vertical(:center)
        result = style.render("X")
        assert_equal " \nX\n ", strip_ansi(result)
      end

      it "accepts :top symbol" do
        style = Style.new.height(3).align_vertical(:top)
        result = style.render("X")
        assert_equal "X\n \n ", strip_ansi(result)
      end

      it "accepts :bottom symbol" do
        style = Style.new.height(3).align_vertical(:bottom)
        result = style.render("X")
        assert_equal " \n \nX", strip_ansi(result)
      end
    end

    describe "Style#align with symbols" do
      it "accepts two symbol arguments" do
        style = Style.new.width(5).height(3).align(:center, :center)
        result = style.render("X")
        assert_equal "     \n  X  \n     ", strip_ansi(result)
      end
    end
  end
end
