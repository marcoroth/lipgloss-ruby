# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class StyleTest < Minitest::Spec
    it "renders basic text" do
      style = Lipgloss::Style.new
      result = style.render("Hello")

      assert_equal "Hello", strip_ansi(result)
    end

    it "renders bold text" do
      style = Lipgloss::Style.new.bold(true)
      result = style.render("Bold")

      assert_equal "Bold", strip_ansi(result)
    end

    it "renders italic text" do
      style = Lipgloss::Style.new.italic(true)
      result = style.render("Italic")

      assert_equal "Italic", strip_ansi(result)
    end

    it "renders underline text" do
      style = Lipgloss::Style.new.underline(true)
      result = style.render("Underline")

      assert_equal "Underline", strip_ansi(result)
    end

    it "renders with foreground color" do
      style = Lipgloss::Style.new.foreground("#FF0000")
      result = style.render("Red")

      assert_equal "Red", strip_ansi(result)
    end

    it "renders with background color" do
      style = Lipgloss::Style.new.background("#0000FF")
      result = style.render("Blue BG")

      assert_equal "Blue BG", strip_ansi(result)
    end

    it "renders with width" do
      style = Lipgloss::Style.new.width(20)
      result = style.render("Short")

      assert_equal 20, Lipgloss.width(result)
    end

    it "renders with padding" do
      style = Lipgloss::Style.new.padding(1, 2)
      result = style.render("Padded")

      assert_equal "          \n  Padded  \n          ", strip_ansi(result)
    end

    it "renders with individual padding" do
      style = Lipgloss::Style.new
                             .padding_top(1)
                             .padding_right(2)
                             .padding_bottom(1)
                             .padding_left(2)

      result = style.render("Padded")

      assert_equal "          \n  Padded  \n          ", strip_ansi(result)
    end

    it "renders with margin" do
      style = Lipgloss::Style.new.margin(1, 2)
      result = style.render("Margin")

      assert_equal "          \n  Margin  \n          ", strip_ansi(result)
    end

    it "renders with rounded border" do
      style = Lipgloss::Style.new.border(:rounded)
      result = style.render("Bordered")

      assert_equal "╭────────╮\n│Bordered│\n╰────────╯", strip_ansi(result)
    end

    it "renders border with specific sides" do
      style = Lipgloss::Style.new.border(:normal, true, false, true, false)
      result = style.render("Top and Bottom")

      assert_equal "──────────────\nTop and Bottom\n──────────────", strip_ansi(result)
    end

    it "renders border foreground color" do
      style = Lipgloss::Style.new.border(:rounded).border_foreground("#FF00FF")
      result = style.render("Colored Border")

      assert_equal "╭──────────────╮\n│Colored Border│\n╰──────────────╯", strip_ansi(result)
    end

    it "aligns text horizontally" do
      style = Lipgloss::Style.new.width(20).align_horizontal(Lipgloss::CENTER)
      result = style.render("Center")

      assert_equal "       Center       ", strip_ansi(result)
    end

    it "aligns text vertically" do
      style = Lipgloss::Style.new.height(3).align_vertical(Lipgloss::CENTER)
      result = style.render("Middle")

      assert_equal "      \nMiddle\n      ", strip_ansi(result)
    end

    it "renders inline without newlines" do
      style = Lipgloss::Style.new.inline(true)
      result = style.render("Inline")

      assert_equal "Inline", strip_ansi(result)
      refute_includes result, "\n"
    end

    it "respects max width" do
      style = Lipgloss::Style.new.max_width(10)
      result = style.render("This is a long text")
      lines = strip_ansi(result).split("\n")

      lines.each do |line|
        assert line.length <= 10, "Line too long: #{line.length}"
      end
    end

    it "chains multiple styles" do
      style = Lipgloss::Style.new
                             .bold(true)
                             .foreground("#FFFFFF")
                             .background("#000000")
                             .padding(1)
                             .border(:rounded)
                             .border_foreground("#FF0000")

      result = style.render("Chained Style")
      stripped = strip_ansi(result)

      assert_includes stripped, "Chained Style"
      assert_includes stripped, "╭"
      assert_includes stripped, "╯"
    end

    it "maintains immutability" do
      style1 = Lipgloss::Style.new
      style2 = style1.bold(true)

      refute_equal style1.object_id, style2.object_id
    end

    it "renders with adaptive color" do
      color = Lipgloss::AdaptiveColor.new(light: "#000000", dark: "#FFFFFF")
      style = Lipgloss::Style.new.foreground(color)
      result = style.render("Adaptive")

      assert_equal "Adaptive", strip_ansi(result)
    end

    it "renders with complete color foreground" do
      color = Lipgloss::CompleteColor.new(
        true_color: "#FF0000",
        ansi256: "196",
        ansi: "9"
      )

      style = Lipgloss::Style.new.foreground(color)
      result = style.render("Red")

      assert_equal "Red", strip_ansi(result)
    end

    it "renders with complete color background" do
      color = Lipgloss::CompleteColor.new(
        true_color: "#0000FF",
        ansi256: "21",
        ansi: "4"
      )

      style = Lipgloss::Style.new.background(color)
      result = style.render("Blue BG")

      assert_equal "Blue BG", strip_ansi(result)
    end

    it "renders with complete adaptive color" do
      light = Lipgloss::CompleteColor.new(true_color: "#000", ansi256: "0", ansi: "0")
      dark = Lipgloss::CompleteColor.new(true_color: "#FFF", ansi256: "15", ansi: "15")
      color = Lipgloss::CompleteAdaptiveColor.new(light: light, dark: dark)

      style = Lipgloss::Style.new.foreground(color)
      result = style.render("Adaptive Complete")

      assert_equal "Adaptive Complete", strip_ansi(result)
    end

    it "converts complete color to hash" do
      color = Lipgloss::CompleteColor.new(
        true_color: "#FF0000",
        ansi256: "196",
        ansi: "9"
      )

      expected = { true_color: "#FF0000", ansi256: "196", ansi: "9" }

      assert_equal expected, color.to_h
    end

    it "renders border top foreground" do
      style = Lipgloss::Style.new
                             .border(:rounded)
                             .border_top_foreground("#FF0000")
      result = style.render("Test")

      assert_equal "╭────╮\n│Test│\n╰────╯", strip_ansi(result)
    end

    it "renders border right foreground" do
      style = Lipgloss::Style.new.border(:rounded).border_right_foreground("#00FF00")
      result = style.render("Test")

      assert_equal "╭────╮\n│Test│\n╰────╯", strip_ansi(result)
    end

    it "renders border bottom foreground" do
      style = Lipgloss::Style.new.border(:rounded).border_bottom_foreground("#0000FF")
      result = style.render("Test")

      assert_equal "╭────╮\n│Test│\n╰────╯", strip_ansi(result)
    end

    it "renders border left foreground" do
      style = Lipgloss::Style.new.border(:rounded).border_left_foreground("#FFFF00")
      result = style.render("Test")

      assert_equal "╭────╮\n│Test│\n╰────╯", strip_ansi(result)
    end

    it "renders border top background" do
      style = Lipgloss::Style.new
                             .border(:rounded)
                             .border_top_background("#FF0000")
      result = style.render("Test")

      assert_equal "╭────╮\n│Test│\n╰────╯", strip_ansi(result)
    end

    it "renders border with all sides different colors" do
      style = Lipgloss::Style.new
                             .border(:rounded)
                             .border_top_foreground("#FF0000")
                             .border_right_foreground("#00FF00")
                             .border_bottom_foreground("#0000FF")
                             .border_left_foreground("#FFFF00")

      result = style.render("Rainbow Border")

      assert_equal "╭──────────────╮\n│Rainbow Border│\n╰──────────────╯", strip_ansi(result)
    end

    it "sets string for to_s output" do
      style = Lipgloss::Style.new.bold(true).set_string("Hello, World!")
      result = style.to_s

      assert_equal "Hello, World!", strip_ansi(result)
    end

    it "returns new style from set_string" do
      style1 = Lipgloss::Style.new
      style2 = style1.set_string("Test")
      refute_equal style1.object_id, style2.object_id
    end

    it "inherits from parent style" do
      parent = Lipgloss::Style.new.foreground("#FF0000").bold(true)
      child = Lipgloss::Style.new.inherit(parent)

      result = child.render("Inherited")

      assert_equal "Inherited", strip_ansi(result)
    end

    it "does not override set rules on inherit" do
      parent = Lipgloss::Style.new
                              .foreground("#FF0000")

      child = Lipgloss::Style.new
                             .foreground("#00FF00")
                             .inherit(parent)

      result = child.render("Test")

      assert_equal "Test", strip_ansi(result)
    end

    it "returns new style from inherit" do
      parent = Lipgloss::Style.new.bold(true)
      child = Lipgloss::Style.new
      inherited = child.inherit(parent)
      refute_equal child.object_id, inherited.object_id
    end

    it "unsets bold" do
      style = Lipgloss::Style.new
                             .bold(true)
                             .unset_bold
      result = style.render("Not Bold")

      assert_equal "Not Bold", strip_ansi(result)
    end

    it "unsets italic" do
      style = Lipgloss::Style.new
                             .italic(true)
                             .unset_italic
      result = style.render("Not Italic")

      assert_equal "Not Italic", strip_ansi(result)
    end

    it "unsets foreground" do
      style = Lipgloss::Style.new
                             .foreground("#FF0000")
                             .unset_foreground
      result = style.render("No Color")

      assert_equal "No Color", strip_ansi(result)
    end

    it "unsets width" do
      style = Lipgloss::Style.new
                             .width(50)
                             .unset_width
      result = style.render("No Width")

      assert_equal "No Width", strip_ansi(result)
    end

    it "unsets padding top" do
      style = Lipgloss::Style.new
                             .padding_top(2)
                             .unset_padding_top
      result = style.render("Test")

      assert_equal "Test", strip_ansi(result)
    end

    it "unsets margin left" do
      style = Lipgloss::Style.new.margin_left(2).unset_margin_left
      result = style.render("Test")

      assert_equal "Test", strip_ansi(result)
    end

    it "unsets border style" do
      style = Lipgloss::Style.new.border(:rounded).unset_border_style
      result = style.render("No Border")

      assert_equal "No Border", strip_ansi(result)
    end

    it "returns new style from unset" do
      style1 = Lipgloss::Style.new.bold(true)
      style2 = style1.unset_bold

      refute_equal style1.object_id, style2.object_id
    end

    it "renders custom border" do
      style = Lipgloss::Style.new
                             .border_custom(
                               top: "~",
                               bottom: "~",
                               left: "|",
                               right: "|",
                               top_left: "+",
                               top_right: "+",
                               bottom_left: "+",
                               bottom_right: "+"
                             )
      result = style.render("Custom")

      assert_equal "+~~~~~~+\n|Custom|\n+~~~~~~+", strip_ansi(result)
    end

    it "renders partial custom border" do
      style = Lipgloss::Style.new
                             .border_custom(
                               top: "-",
                               bottom: "-"
                             )
      result = style.render("Partial")

      assert_equal " ------- \n Partial \n ------- ", strip_ansi(result)
    end

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

    # ---- Truncation (max_width) ----

    it "truncates single long word" do
      style = Style.new.max_width(5)
      result = style.render("ABCDEFGHIJ")
      assert_equal "ABCDE", strip_ansi(result)
    end

    it "truncates long lines" do
      style = Style.new.max_width(10)
      result = style.render("one two three four five")
      assert_equal "one two th", strip_ansi(result)
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

    # ---- Style.width wraps and pads ----

    it "wraps text and pads to width" do
      s = Style.new.width(10)
      result = s.render("hello  world")
      lines = result.split("\n")
      assert_equal 2, lines.length
      lines.each { |l| assert_equal 10, Ansi.width(l) }
    end

    # ---- ANSI styling does not bleed into padding ----

    it "does not apply background color to padding spaces" do
      style = Style.new.background("#FF0000").padding(0, 2)
      result = style.render("Hi")
      # The padding spaces should NOT be wrapped in ANSI codes
      # Content "Hi" should have ANSI, padding spaces should be plain
      assert_includes result, "\e[48;2;255;0;0m"
      # After RESET, padding spaces should be plain
      lines = result.split("\n")
      lines.each do |line|
        # Line should start with plain spaces (padding), not ANSI
        assert_match(/\A  /, line, "Padding should be plain spaces, not styled")
      end
    end

    it "does not apply foreground color to padding lines" do
      style = Style.new.foreground("#FF0000").padding(1, 0)
      result = style.render("Hi")
      lines = result.split("\n")
      # Top padding line should be plain spaces (no ANSI)
      refute_includes lines[0], "\e[", "Padding line should not contain ANSI codes"
      # Content line should have ANSI
      assert_includes lines[1], "\e[38;2;255;0;0m"
    end

    # ---- Inline mode strips input newlines, not output ----

    it "inline strips input newlines but preserves border structure" do
      style = Style.new.inline(true).border(:rounded)
      result = strip_ansi(style.render("A\nB"))
      # inline strips input newlines: "A\nB" -> "AB"
      # border still renders as multi-line
      assert_includes result, "╭"
      assert_includes result, "╰"
      assert_includes result, "AB"
      assert result.include?("\n"), "Border should produce multi-line output"
    end

    it "inline skips word wrapping" do
      style = Style.new.inline(true).width(5)
      result = strip_ansi(style.render("Hello World"))
      # inline strips newlines and skips wrapping, but alignment still pads
      refute_includes result, "\n"
    end

    # ---- Height includes padding ----

    it "height includes padding lines" do
      style = Style.new.height(5).padding_top(1)
      result = style.render("Hi")
      lines = result.split("\n")
      assert_equal 5, lines.length, "Total height should be 5 (including padding)"
    end

    it "height includes bottom padding" do
      style = Style.new.height(4).padding_bottom(1).padding_top(1)
      result = style.render("X")
      lines = result.split("\n")
      assert_equal 4, lines.length, "Total height should be 4 (including top and bottom padding)"
    end

    # ---- Truncation emits RESET ----

    it "truncation emits RESET when ANSI codes present" do
      style = Style.new.foreground("#FF0000").max_width(3)
      result = style.render("Hello")
      assert result.end_with?("\e[0m"), "Truncated ANSI line should end with RESET"
    end

    it "truncation does not emit RESET for plain text" do
      style = Style.new.max_width(3)
      result = style.render("Hello")
      assert_equal "Hel", result
      refute result.end_with?("\e[0m")
    end

    # ---- Truncation with ANSI sequences ----

    it "truncates ANSI-colored text correctly" do
      style = Style.new.foreground("#00FF00").max_width(5)
      result = style.render("ABCDEFGH")
      assert_equal "ABCDE", strip_ansi(result)
      assert_includes result, "\e[38;2;0;255;0m"
      assert result.end_with?("\e[0m")
    end
  end
end
