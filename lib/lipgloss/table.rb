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
      @style_func_block = nil
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

    # Set a style function that determines the style for each cell.
    # The block is evaluated lazily during render.
    #
    # @example Alternating row colors
    #   table.style_func do |row, column|
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
    #   table.style_func do |row, column|
    #     case column
    #     when 0 then Lipgloss::Style.new.bold(true)
    #     when 1 then Lipgloss::Style.new.foreground("#00FF00")
    #     else Lipgloss::Style.new
    #     end
    #   end
    #
    # @rbs rows: Integer? -- deprecated, ignored
    # @rbs columns: Integer? -- deprecated, ignored
    # @rbs &block: (Integer, Integer) -> Style? -- block called for each cell position
    # @rbs return: Table -- a new table with the style function applied
    def style_func(rows: nil, columns: nil, &block) # rubocop:disable Lint/UnusedMethodArgument
      raise ArgumentError, "block required" unless block_given?

      dup_with { |t| t.instance_variable_set(:@style_func_block, block) }
    end # rubocop:enable Lint/UnusedMethodArgument

    def render # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
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
      lines << build_horizontal_border(col_widths, chars, :header) if @border_header && @headers.any?

      # Data rows
      @rows.each_with_index do |row_data, row_idx|
        # Row separator (between data rows)
        lines << build_horizontal_border(col_widths, chars, :row) if @border_row && row_idx.positive?
        lines << build_data_row(row_data, col_widths, chars, row_idx)
      end

      # Bottom border
      lines << build_horizontal_border(col_widths, chars, :bottom) if @border_bottom

      # Pad all lines to the same width (needed when border chars are empty)
      max_line_width = lines.map { |l| Ansi.width(l) }.max || 0
      lines = lines.map do |l|
        lw = Ansi.width(l)
        lw < max_line_width ? l + (" " * (max_line_width - lw)) : l
      end

      # Apply height constraint
      if @height.positive? && lines.length != @height
        if lines.length < @height
          blank = " " * max_line_width
          lines += Array.new(@height - lines.length, blank)
        else
          lines = lines[0...@height]
        end
      end

      lines.join("\n")
    end # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    alias to_s render

    private

    def calculate_column_widths(num_cols) # rubocop:disable Metrics/AbcSize
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
    end # rubocop:enable Metrics/AbcSize

    def distribute_width(col_widths, num_cols) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      border_overhead = 0
      border_overhead += 1 if @border_left
      border_overhead += 1 if @border_right
      border_overhead += (num_cols - 1) if @border_column && num_cols > 1

      result = col_widths.dup

      # Shrink: reduce the widest column by 1 until we fit
      loop do
        total = result.sum + border_overhead
        break if total <= @width

        max_idx = 0
        max_val = result[0]
        (1...num_cols).each do |i|
          if result[i] > max_val
            max_val = result[i]
            max_idx = i
          end
        end

        break if max_val <= 1

        result[max_idx] -= 1
      end

      # Expand: add 1 to the shortest column until we reach target width
      loop do
        total = result.sum + border_overhead
        break if total >= @width

        min_idx = 0
        min_val = result[0]
        (1...num_cols).each do |i|
          if result[i] < min_val
            min_val = result[i]
            min_idx = i
          end
        end

        result[min_idx] += 1
      end

      result
    end # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def build_horizontal_border(col_widths, chars, position) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      corner_left, corner_right, horizontal, separator = case position
                                                         when :top
                                                           [chars[:top_left], chars[:top_right], chars[:top], chars[:middle_top]]
                                                         when :header
                                                           [chars[:middle_left], chars[:middle_right], chars[:top], chars[:middle]]
                                                         when :row
                                                           [chars[:middle_left], chars[:middle_right], chars[:bottom], chars[:middle]]
                                                         when :bottom
                                                           [chars[:bottom_left], chars[:bottom_right], chars[:bottom], chars[:middle_bottom]]
                                                         end

      line = ""
      line += style_border_char(corner_left) if @border_left && !corner_left.empty?

      col_widths.each_with_index do |w, i|
        line += style_border_char(horizontal * w)
        line += style_border_char(separator) if i < col_widths.length - 1 && @border_column && !separator.empty?
      end

      line += style_border_char(corner_right) if @border_right && !corner_right.empty?
      line
    end # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def build_data_row(row_data, col_widths, chars, row_idx) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
      line = ""
      line += style_border_char(chars[:left]) if @border_left

      col_widths.each_with_index do |w, i|
        cell_text = (row_data[i] || "").to_s

        # Apply style_func if available
        if @style_func_block
          style = @style_func_block.call(row_idx, i)
          cell_text = style.render(cell_text) if style
        end

        cell_width = Ansi.width(cell_text)
        if cell_width > w
          cell_text = Ansi.truncate(cell_text, w)
          cell_width = Ansi.width(cell_text)
        end
        padded = cell_text + (" " * [w - cell_width, 0].max)
        line += padded

        line += style_border_char(chars[:left]) if i < col_widths.length - 1 && @border_column
      end

      line += style_border_char(chars[:right]) if @border_right
      line
    end # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

    def style_border_char(char)
      return char unless @border_style_obj

      @border_style_obj.render(char)
    end
  end
end
