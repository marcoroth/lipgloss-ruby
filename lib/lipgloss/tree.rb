# frozen_string_literal: true

module Lipgloss
  class Tree
    include Immutable

    ENUMERATOR_CHARS = {
      default: { mid: "├── ", last: "└── ", mid_cont: "│   ", last_cont: "    " },
      rounded: { mid: "├── ", last: "╰── ", mid_cont: "│   ", last_cont: "    " }
    }.freeze

    def initialize(root = nil)
      @root = root
      @children = []
      @enumerator_type = :default
      @enumerator_style = nil
      @item_style = nil
      @root_style = nil
    end

    def self.root(root)
      new(root)
    end

    def root=(root_val)
      dup_with { |t| t.instance_variable_set(:@root, root_val) }
    end

    def child(*children)
      dup_with { |t| t.instance_variable_set(:@children, @children + children) }
    end

    def children(children)
      dup_with { |t| t.instance_variable_set(:@children, @children + children) }
    end

    def enumerator(type)
      dup_with { |t| t.instance_variable_set(:@enumerator_type, type) }
    end

    def enumerator_style(style)
      dup_with { |t| t.instance_variable_set(:@enumerator_style, style) }
    end

    def item_style(style)
      dup_with { |t| t.instance_variable_set(:@item_style, style) }
    end

    def root_style(style)
      dup_with { |t| t.instance_variable_set(:@root_style, style) }
    end

    def render # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      lines = []

      # Root
      root_text = @root.to_s
      root_text = @root_style.render(root_text) if @root_style
      lines << root_text

      # Children
      chars = ENUMERATOR_CHARS[@enumerator_type] || ENUMERATOR_CHARS[:default]

      @children.each_with_index do |child_item, i|
        is_last = (i == @children.length - 1)
        prefix = is_last ? chars[:last] : chars[:mid]
        continuation = is_last ? chars[:last_cont] : chars[:mid_cont]

        if child_item.is_a?(Tree)
          # Render subtree
          sub_lines = child_item.render.split("\n", -1)

          # First line of subtree (the root)
          sub_root = sub_lines[0]
          styled_prefix = if @enumerator_style
                            "#{@enumerator_style.render(prefix.rstrip)} "
                          else
                            prefix
                          end

          sub_root = @item_style.render(sub_root) if @item_style

          lines << (styled_prefix + sub_root)

          # Remaining lines (children of subtree)
          sub_lines[1..].each do |sub_line|
            lines << (continuation + sub_line)
          end
        else
          item_text = child_item.to_s
          item_text = @item_style.render(item_text) if @item_style

          styled_prefix = if @enumerator_style
                            "#{@enumerator_style.render(prefix.rstrip)} "
                          else
                            prefix
                          end

          lines << (styled_prefix + item_text)
        end
      end

      lines.join("\n")
    end # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    alias to_s render
  end
end
