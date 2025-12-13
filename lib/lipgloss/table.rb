# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  # Ruby enhancements for the Table class
  #
  # The Table class is implemented in C, but this module adds
  # Ruby-level conveniences like style_func with blocks.
  class Table
    # Header row constant (used in style_func)
    HEADER_ROW = -1

    # Set a style function that determines the style for each cell
    #
    # @example Alternating row colors
    #   table.style_func(rows: 2, columns: 2) do |row, column|
    #     if row == Lipgloss::Table::HEADER_ROW
    #       Lipgloss::Style.new.bold(true)
    #     elsif row.even?
    #       Lipgloss::Style.new.background("#333")
    #     else
    #       Lipgloss::Style.new.background("#444")
    #     end
    #   end
    #
    # @example Column-specific styling
    #   table.style_func(rows: 2, columns: 2) do |row, column|
    #     case column
    #     when 0 then Lipgloss::Style.new.bold(true)
    #     when 1 then Lipgloss::Style.new.foreground("#00FF00")
    #     else Lipgloss::Style.new
    #     end
    #   end
    #
    # @rbs rows: Integer -- number of data rows in the table
    # @rbs columns: Integer -- number of columns in the table
    # @rbs &block: (Integer, Integer) -> Style? -- block called for each cell position
    # @rbs return: Table -- a new table with the style function applied
    def style_func(rows:, columns:, &block)
      raise ArgumentError, "block required" unless block_given?
      raise ArgumentError, "rows must be >= 0" if rows.negative?
      raise ArgumentError, "columns must be > 0" if columns <= 0

      style_map = {} #: Hash[String, Style]

      # Header row
      columns.times do |column|
        style = block.call(HEADER_ROW, column)
        style_map["#{HEADER_ROW},#{column}"] = style if style
      end

      # Data rows
      rows.times do |row|
        columns.times do |column|
          style = block.call(row, column)
          style_map["#{row},#{column}"] = style if style
        end
      end

      _style_func_map(style_map)
    end
  end
end
