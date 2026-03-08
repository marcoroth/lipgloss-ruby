# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class PureRubyTest < Minitest::Spec
    # ---- ANSI code verification ----

    it "emits bold ANSI codes" do
      style = Style.new.bold(true)
      result = style.render("Bold")
      assert_includes result, "\e[1m"
      assert_includes result, "\e[0m"
    end

    it "emits italic ANSI codes" do
      style = Style.new.italic(true)
      result = style.render("Italic")
      assert_includes result, "\e[3m"
    end

    it "emits foreground color ANSI codes" do
      style = Style.new.foreground("#FF0000")
      result = style.render("Red")
      assert_includes result, "\e[38;2;255;0;0m"
    end

    it "emits background color ANSI codes" do
      style = Style.new.background("#00FF00")
      result = style.render("Green")
      assert_includes result, "\e[48;2;0;255;0m"
    end

    it "emits combined ANSI codes" do
      style = Style.new.bold(true).italic(true).foreground("#0000FF")
      result = style.render("Blue Bold Italic")
      assert_includes result, "\e[1m"
      assert_includes result, "\e[3m"
      assert_includes result, "\e[38;2;0;0;255m"
    end

    it "applies ANSI codes per line" do
      style = Style.new.bold(true)
      result = style.render("Line1\nLine2")
      lines = result.split("\n")
      lines.each do |line|
        assert_includes line, "\e[1m"
        assert_includes line, "\e[0m"
      end
    end

    it "does not apply ANSI codes to empty lines" do
      style = Style.new.bold(true)
      result = style.render("X\n\nY")
      lines = result.split("\n")
      # Middle line is empty and should NOT have bold codes
      assert_equal "", lines[1]
      assert_includes lines[0], "\e[1m"
      assert_includes lines[2], "\e[1m"
    end

    # ---- Tab conversion ----

    it "converts tabs to spaces with default tab width" do
      style = Style.new
      result = style.render("A\tB")
      assert_equal "A    B", strip_ansi(result)
    end

    it "converts tabs with custom tab width" do
      style = Style.new.tab_width(2)
      result = style.render("A\tB")
      assert_equal "A  B", strip_ansi(result)
    end

    it "removes tabs when tab_width is 0" do
      style = Style.new.tab_width(0)
      result = style.render("A\tB")
      assert_equal "AB", strip_ansi(result)
    end

    it "preserves tabs when tab_width is NO_TAB_CONVERSION" do
      style = Style.new.tab_width(Lipgloss::NO_TAB_CONVERSION)
      result = style.render("A\tB")
      assert_equal "A\tB", strip_ansi(result)
    end

    # ---- Style getters ----

    it "returns correct bold? value" do
      assert_equal false, Style.new.bold?
      assert_equal true, Style.new.bold(true).bold?
      assert_equal false, Style.new.bold(true).unset_bold.bold?
    end

    it "returns correct get_foreground" do
      assert_nil Style.new.get_foreground
      assert_equal "#FF0000", Style.new.foreground("#FF0000").get_foreground
      assert_nil Style.new.foreground("#FF0000").unset_foreground.get_foreground
    end

    it "returns correct get_width" do
      assert_equal 0, Style.new.get_width
      assert_equal 20, Style.new.width(20).get_width
      assert_equal 0, Style.new.width(20).unset_width.get_width
    end

    it "returns correct get_height" do
      assert_equal 0, Style.new.get_height
      assert_equal 5, Style.new.height(5).get_height
    end

    # ---- Word wrapping edge cases ----

    it "wraps single long word" do
      style = Style.new.max_width(5)
      result = style.render("ABCDEFGHIJ")
      lines = strip_ansi(result).split("\n")
      lines.each { |l| assert l.length <= 5, "Line too long: '#{l}'" }
      assert_equal "ABCDEFGHIJ", lines.join
    end

    it "wraps multiple words" do
      style = Style.new.max_width(10)
      result = style.render("one two three four five")
      lines = strip_ansi(result).split("\n")
      lines.each { |l| assert l.length <= 10, "Line too long: '#{l}' (#{l.length})" }
    end

    it "preserves short text with max_width" do
      style = Style.new.max_width(20)
      result = style.render("Short")
      assert_equal "Short", strip_ansi(result)
    end

    # ---- Combined styles ----

    it "combines padding + border" do
      style = Style.new.padding(0, 1).border(:rounded)
      result = strip_ansi(style.render("Hi"))
      assert_includes result, "╭"
      assert_includes result, "╯"
      assert_includes result, " Hi "
    end

    it "combines width + alignment + border" do
      style = Style.new.width(10).align_horizontal(:center).border(:rounded)
      result = strip_ansi(style.render("Hi"))
      lines = result.split("\n")
      # All lines should be 12 wide (10 content + 2 border)
      lines.each { |l| assert_equal 12, l.length, "Line: '#{l}'" }
    end

    # ---- Empty content ----

    it "renders empty string" do
      style = Style.new
      result = style.render("")
      assert_equal "", strip_ansi(result)
    end

    it "renders empty string with border" do
      style = Style.new.border(:rounded)
      result = strip_ansi(style.render(""))
      assert_includes result, "╭╮"
      assert_includes result, "╰╯"
    end

    it "renders empty string with width" do
      style = Style.new.width(5)
      result = strip_ansi(style.render(""))
      assert_equal "     ", result
    end

    # ---- Table with border_row ----

    it "renders table with border_row enabled" do
      table = Table.new
                   .headers(["X"])
                   .rows([["A"], ["B"]])
                   .border(:normal)
                   .border_row(true)

      result = strip_ansi(table.render)
      # Should have row separator between A and B
      assert_includes result, "├─┤"
    end

    # ---- Table with border_style ----

    it "applies border_style to table borders" do
      border_s = Style.new.foreground("#FF0000")
      table = Table.new
                   .headers(["X"])
                   .rows([["Y"]])
                   .border_style(border_s)

      result = table.render
      # Border characters should have ANSI codes
      assert_includes result, "\e["
      assert_equal "╭─╮\n│X│\n├─┤\n│Y│\n╰─╯", strip_ansi(result)
    end

    # ---- Ansi module ----

    it "strips ANSI codes" do
      assert_equal "Hello", Ansi.strip("\e[1mHello\e[0m")
      assert_equal "test", Ansi.strip("\e[38;2;255;0;0mtest\e[0m")
    end

    it "calculates width correctly" do
      assert_equal 5, Ansi.width("Hello")
      assert_equal 5, Ansi.width("\e[1mHello\e[0m")
      assert_equal 5, Ansi.width("Hello\nHi")
    end

    it "calculates height correctly" do
      assert_equal 1, Ansi.height("Hello")
      assert_equal 3, Ansi.height("A\nB\nC")
    end

    # ---- Color module ----

    it "generates foreground ANSI code from hex" do
      assert_equal "\e[38;2;255;0;0m", Color.to_ansi_fg("#FF0000")
      assert_equal "\e[38;2;255;0;0m", Color.to_ansi_fg("#F00")
    end

    it "generates background ANSI code from hex" do
      assert_equal "\e[48;2;0;255;0m", Color.to_ansi_bg("#00FF00")
    end

    it "handles adaptive color" do
      color = AdaptiveColor.new(light: "#000000", dark: "#FFFFFF")
      result = Color.to_ansi_fg(color)
      refute_empty result
    end

    it "handles complete color" do
      color = CompleteColor.new(true_color: "#FF0000", ansi256: "196", ansi: "9")
      result = Color.to_ansi_fg(color)
      refute_empty result
    end

    # ---- Inherit edge cases ----

    it "inherits multiple properties" do
      parent = Style.new.bold(true).italic(true).foreground("#FF0000")
      child = Style.new.inherit(parent)

      assert_equal true, child.bold?
      assert_equal true, child.italic?
      assert_equal "#FF0000", child.get_foreground
    end

    it "child properties take precedence over inherited" do
      parent = Style.new.bold(true).foreground("#FF0000")
      child = Style.new.bold(false).inherit(parent)

      assert_equal false, child.bold?
      assert_equal "#FF0000", child.get_foreground
    end

    # ---- Deeply nested tree ----

    it "renders deeply nested tree" do
      inner = Tree.root("C").child("D")
      mid = Tree.root("B").child(inner)
      tree = Tree.root("A").child(mid)

      result = strip_ansi(tree.render)
      expected = "A\n└── B\n    └── C\n        └── D"
      assert_equal expected, result
    end

    # ---- Nested list with different enumerators ----

    it "renders nested list inheriting parent enumerator" do
      inner = List.new("X", "Y").enumerator(:arabic)
      outer = List.new.item("Main").item(inner)

      result = strip_ansi(outer.render)
      assert_includes result, "• Main"
      assert_includes result, "  1. X"
      assert_includes result, "  2. Y"
    end
  end
end
