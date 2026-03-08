# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  class Table
    include Immutable

    # Header row constant (used in style_func)
    HEADER_ROW = -1

    def initialize
      @headers = []
      @rows = []
      @border_type = :rounded
      @border_top = true
      @border_bottom = true
      @border_left = true
      @border_right = true
      @border_header = true
      @border_column = true
      @border_row = false
      @width = 0
      @height = 0
      @border_style_obj = nil
      @style_map = nil
    end

    def headers(headers)
      dup_with { |t| t.instance_variable_set(:@headers, headers.dup) }
    end

    def row(row)
      dup_with { |t| t.instance_variable_set(:@rows, @rows.dup + [row.dup]) }
    end

    def rows(rows)
      dup_with { |t| t.instance_variable_set(:@rows, rows.map(&:dup)) }
    end

    def clear_rows
      dup_with { |t| t.instance_variable_set(:@rows, []) }
    end

    def border(border_sym)
      dup_with { |t| t.instance_variable_set(:@border_type, border_sym) }
    end

    def border_style(style)
      dup_with { |t| t.instance_variable_set(:@border_style_obj, style) }
    end

    [:border_top, :border_bottom, :border_left, :border_right, :border_header, :border_column, :border_row].each do |method|
      define_method(method) do |value|
        dup_with { |t| t.instance_variable_set(:"@#{method}", value) }
      end
    end

    [:width, :height].each do |method|
      define_method(method) do |value|
        dup_with { |t| t.instance_variable_set(:"@#{method}", value) }
      end
    end

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

      style_map = {}

      # Header row
      columns.times do |column|
        style = block.call(HEADER_ROW, column)
        style_map[[HEADER_ROW, column]] = style if style
      end

      # Data rows
      rows.times do |row_idx|
        columns.times do |column|
          style = block.call(row_idx, column)
          style_map[[row_idx, column]] = style if style
        end
      end

      dup_with { |t| t.instance_variable_set(:@style_map, style_map) }
    end

    def render
      num_cols = [@headers.length, *@rows.map(&:length)].max || 0
      return "" if num_cols.zero?

      chars = Border.chars_for(@border_type)

      # Calculate column widths
      col_widths = calculate_column_widths(num_cols)

      # Apply width constraint
      col_widths = distribute_width(col_widths, num_cols) if @width.positive?

      lines = []

      # Top border
      lines << build_horizontal_border(col_widths, chars, :top) if @border_top

      # Header row
      lines << build_data_row(@headers, col_widths, chars, HEADER_ROW) if @headers.any?

      # Header separator
      lines << build_horizontal_border(col_widths, chars, :middle) if @border_header && @headers.any?

      # Data rows
      @rows.each_with_index do |row_data, row_idx|
        # Row separator (between data rows)
        lines << build_horizontal_border(col_widths, chars, :middle) if @border_row && row_idx.positive?
        lines << build_data_row(row_data, col_widths, chars, row_idx)
      end

      # Bottom border
      lines << build_horizontal_border(col_widths, chars, :bottom) if @border_bottom

      lines.join("\n")
    end

    alias to_s render

    private

    def calculate_column_widths(num_cols)
      widths = Array.new(num_cols, 0)

      @headers.each_with_index do |header, i|
        w = Ansi.width(header.to_s)
        widths[i] = w if w > widths[i]
      end

      @rows.each do |row_data|
        row_data.each_with_index do |cell, i|
          next if i >= num_cols

          w = Ansi.width(cell.to_s)
          widths[i] = w if w > widths[i]
        end
      end

      widths
    end

    def distribute_width(col_widths, num_cols)
      border_overhead = 0
      border_overhead += 1 if @border_left
      border_overhead += 1 if @border_right
      border_overhead += (num_cols - 1) if @border_column && num_cols > 1

      available = @width - border_overhead
      return col_widths if available <= 0

      current_total = col_widths.sum
      if current_total < available
        extra = available - current_total
        base_extra = extra / num_cols
        remainder = extra % num_cols

        col_widths.each_with_index.map do |w, i|
          w + base_extra + (i < remainder ? 1 : 0)
        end
      else
        col_widths
      end
    end

    def build_horizontal_border(col_widths, chars, position)
      corner_left, corner_right, horizontal, separator = case position
                                                         when :top
                                                           [chars[:top_left], chars[:top_right], chars[:top], chars[:middle_top]]
                                                         when :middle
                                                           [chars[:middle_left], chars[:middle_right], chars[:top], chars[:middle]]
                                                         when :bottom
                                                           [chars[:bottom_left], chars[:bottom_right], chars[:bottom], chars[:middle_bottom]]
                                                         end

      line = ""
      line += style_border_char(corner_left) if @border_left

      col_widths.each_with_index do |w, i|
        line += style_border_char(horizontal * w)
        line += style_border_char(separator) if i < col_widths.length - 1 && @border_column
      end

      line += style_border_char(corner_right) if @border_right
      line
    end

    def build_data_row(row_data, col_widths, chars, row_idx)
      line = ""
      line += style_border_char(chars[:left]) if @border_left

      col_widths.each_with_index do |w, i|
        cell_text = (row_data[i] || "").to_s

        # Apply style_func if available
        if @style_map
          style = @style_map[[row_idx, i]]
          cell_text = style.render(cell_text) if style
        end

        cell_width = Ansi.width(cell_text)
        padded = cell_text + (" " * [w - cell_width, 0].max)
        line += padded

        line += style_border_char(chars[:left]) if i < col_widths.length - 1 && @border_column
      end

      line += style_border_char(chars[:right]) if @border_right
      line
    end

    def style_border_char(char)
      return char unless @border_style_obj

      @border_style_obj.render(char)
    end
  end
end
