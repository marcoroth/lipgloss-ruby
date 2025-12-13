# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class TableTest < Minitest::Spec
    it "renders basic table" do
      table = Lipgloss::Table.new
                             .headers(["Name", "Age"])
                             .rows([["Alice", "25"], ["Bob", "30"]])

      result = strip_ansi(table.render)
      expected = "╭─────┬───╮\n│Name │Age│\n├─────┼───┤\n│Alice│25 │\n│Bob  │30 │\n╰─────┴───╯"

      assert_equal expected, result
    end

    it "renders single row" do
      table = Lipgloss::Table.new
                             .headers(["Col1", "Col2"])
                             .row(["A", "B"])

      result = strip_ansi(table.render)
      expected = "╭────┬────╮\n│Col1│Col2│\n├────┼────┤\n│A   │B   │\n╰────┴────╯"

      assert_equal expected, result
    end

    it "renders with rounded border" do
      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["Y"]])
                             .border(:rounded)

      result = strip_ansi(table.render)
      expected = "╭─╮\n│X│\n├─┤\n│Y│\n╰─╯"

      assert_equal expected, result
    end

    it "renders with normal border" do
      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["Y"]])
                             .border(:normal)

      result = strip_ansi(table.render)
      expected = "┌─┐\n│X│\n├─┤\n│Y│\n└─┘"

      assert_equal expected, result
    end

    it "renders with double border" do
      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["Y"]])
                             .border(:double)

      result = strip_ansi(table.render)
      expected = "╔═╗\n║X║\n╠═╣\n║Y║\n╚═╝"

      assert_equal expected, result
    end

    it "renders with ascii border" do
      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["Y"]])
                             .border(:ascii)

      result = strip_ansi(table.render)
      expected = "+-+\n|X|\n+-+\n|Y|\n+-+"

      assert_equal expected, result
    end

    it "renders with markdown border" do
      table = Lipgloss::Table.new
                             .headers(["X", "Y"])
                             .rows([["A", "B"]])
                             .border(:markdown)
                             .border_top(false)
                             .border_bottom(false)

      result = strip_ansi(table.render)
      expected = "|X|Y|\n|-|-|\n|A|B|"

      assert_equal expected, result
    end

    it "respects width constraint" do
      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["Y"]])
                             .width(40)

      result = table.render
      lines = strip_ansi(result).split("\n")
      lines.each do |line|
        assert line.length <= 40, "Line too long: #{line.length}"
      end
    end

    it "controls border visibility" do
      table = Lipgloss::Table.new
                             .headers(["A", "B"])
                             .rows([["1", "2"]])
                             .border(:normal)
                             .border_top(false)
                             .border_bottom(true)
                             .border_left(true)
                             .border_right(true)

      result = strip_ansi(table.render)
      expected = "│A│B│\n├─┼─┤\n│1│2│\n└─┴─┘"

      assert_equal expected, result
    end

    it "clears rows" do
      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["Y"]])
                             .clear_rows

      result = strip_ansi(table.render)
      expected = "╭─╮\n│X│\n├─┤\n╰─╯"

      assert_equal expected, result
    end

    it "converts to string with to_s" do
      table = Lipgloss::Table.new
                             .headers(["Test"])
                             .rows([["Value"]])

      assert_equal table.render, table.to_s
    end

    it "chains multiple options" do
      table = Lipgloss::Table.new
                             .headers(["A", "B", "C"])
                             .rows([["1", "2", "3"]])
                             .border(:rounded)
                             .border_header(true)
                             .border_column(true)
                             .width(30)

      result = strip_ansi(table.render)
      expected = "╭─────────┬─────────┬────────╮\n│A        │B        │C       │\n├─────────┼─────────┼────────┤\n│1        │2        │3       │\n╰─────────┴─────────┴────────╯"

      assert_equal expected, result
    end

    it "maintains immutability" do
      table1 = Lipgloss::Table.new
      table2 = table1.headers(["X"])

      refute_equal table1.object_id, table2.object_id
    end

    it "applies style_func with header and row styles" do
      header_style = Lipgloss::Style.new.bold(true)
      row_style = Lipgloss::Style.new

      table = Lipgloss::Table.new
                             .headers(["A", "B"])
                             .rows([["1", "2"], ["3", "4"]])
                             .style_func(rows: 2, columns: 2) do |row, _col|
        if row == Lipgloss::Table::HEADER_ROW
          header_style
        else
          row_style
        end
      end

      result = strip_ansi(table.render)
      expected = "╭─┬─╮\n│A│B│\n├─┼─┤\n│1│2│\n│3│4│\n╰─┴─╯"

      assert_equal expected, result
    end

    it "applies style_func with alternating rows" do
      even_style = Lipgloss::Style.new
      odd_style = Lipgloss::Style.new

      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["A"], ["B"], ["C"]])
                             .style_func(rows: 3, columns: 1) do |row, _col|
        row.even? ? even_style : odd_style
      end

      result = strip_ansi(table.render)
      expected = "╭─╮\n│X│\n├─┤\n│A│\n│B│\n│C│\n╰─╯"

      assert_equal expected, result
    end

    it "has HEADER_ROW constant" do
      assert_equal(-1, Lipgloss::Table::HEADER_ROW)
    end

    it "requires block for style_func" do
      table = Lipgloss::Table.new
                             .headers(["X"])
                             .rows([["Y"]])

      assert_raises(ArgumentError) do
        table.style_func(rows: 1, cols: 1)
      end
    end

    it "returns new table from style_func" do
      table1 = Lipgloss::Table.new
                              .headers(["X"])
                              .rows([["Y"]])

      style = Lipgloss::Style.new
      table2 = table1.style_func(rows: 1, columns: 1) { |_r, _c| style }

      refute_equal table1.object_id, table2.object_id
    end
  end
end
