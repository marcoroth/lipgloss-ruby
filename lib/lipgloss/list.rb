# frozen_string_literal: true

module Lipgloss
  class List
    include Immutable

    ENUMERATORS = {
      bullet: ->(_i, _total) { "\u2022 " },
      arabic: ->(i, _total) { "#{i + 1}. " },
      alphabet: ->(i, _total) { "#{("A".ord + i).chr}. " },
      roman: lambda { |i, total|
        numerals = (1..total).map { |n| List.to_roman(n) }
        max_width = numerals.map(&:length).max
        "#{numerals[i].rjust(max_width)}. "
      },
      dash: ->(_i, _total) { "- " },
      asterisk: ->(_i, _total) { "* " }
    }.freeze

    def initialize(*items)
      @items = items.dup
      @enumerator_type = :bullet
      @enumerator_style = nil
      @item_style = nil
    end

    def item(new_item)
      dup_with { |l| l.instance_variable_set(:@items, @items + [new_item]) }
    end

    def items(new_items)
      dup_with { |l| l.instance_variable_set(:@items, new_items.dup) }
    end

    def enumerator(type)
      dup_with { |l| l.instance_variable_set(:@enumerator_type, type) }
    end

    def enumerator_style(style)
      dup_with { |l| l.instance_variable_set(:@enumerator_style, style) }
    end

    def item_style(style)
      dup_with { |l| l.instance_variable_set(:@item_style, style) }
    end

    def render(indent: 0)
      lines = []
      total = @items.length

      @items.each_with_index do |cur_item, i|
        if cur_item.is_a?(List)
          nested = cur_item.render(indent: indent + 2)
          lines << nested
        else
          prefix = ENUMERATORS[@enumerator_type].call(i, total)

          styled_prefix = if @enumerator_style
                            @enumerator_style.render(prefix.rstrip)
                          else
                            prefix
                          end

          item_text = cur_item.to_s
          item_text = @item_style.render(item_text) if @item_style

          lines << "#{" " * indent}#{styled_prefix}#{item_text}"
        end
      end

      lines.join("\n")
    end

    def to_s
      render
    end

    def self.to_roman(n)
      values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
      symbols = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
      result = +""
      values.each_with_index do |val, i|
        while n >= val
          result << symbols[i]
          n -= val
        end
      end
      result
    end
  end
end
