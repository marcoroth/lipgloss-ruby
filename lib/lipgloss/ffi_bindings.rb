# frozen_string_literal: true

require "ffi"
require "json"

module Lipgloss
  # FFI bindings for JRuby (and other non-CRuby implementations)
  # that cannot load C extensions. Loads the Go shared library directly.
  module FFI
    extend ::FFI::Library

    def self.shared_lib_path
      cpu = RbConfig::CONFIG["host_cpu"]
      os = RbConfig::CONFIG["host_os"]

      arch = case cpu
             when /aarch64|arm64/ then "arm64"
             when /x86_64|amd64/ then "amd64"
             when /arm/ then "arm"
             when /i[3-6]86/ then "386"
             else cpu
             end

      goos = case os
             when /darwin/ then "darwin"
             when /mswin|mingw/ then "windows"
             else "linux"
             end

      ext = case os
            when /darwin/ then "dylib"
            when /mswin|mingw/ then "dll"
            else "so"
            end

      platform = "#{goos}_#{arch}"
      File.expand_path("../../go/build/#{platform}/liblipgloss.#{ext}", __dir__)
    end

    ffi_lib shared_lib_path

    # Memory management
    attach_function :lipgloss_free, [:pointer], :void

    # Version
    attach_function :lipgloss_upstream_version, [], :pointer

    # Layout
    attach_function :lipgloss_join_horizontal, [:double, :string], :pointer
    attach_function :lipgloss_join_vertical, [:double, :string], :pointer
    attach_function :lipgloss_width, [:string], :int
    attach_function :lipgloss_height, [:string], :int
    attach_function :lipgloss_place, [:int, :int, :double, :double, :string], :pointer
    attach_function :lipgloss_place_with_whitespace, [:int, :int, :double, :double, :string, :string, :string], :pointer
    attach_function :lipgloss_place_with_whitespace_adaptive, [:int, :int, :double, :double, :string, :string, :string, :string], :pointer
    attach_function :lipgloss_place_horizontal, [:int, :double, :string], :pointer
    attach_function :lipgloss_place_vertical, [:int, :double, :string], :pointer
    attach_function :lipgloss_has_dark_background, [], :int

    # Style lifecycle
    attach_function :lipgloss_new_style, [], :uint64
    attach_function :lipgloss_free_style, [:uint64], :void
    attach_function :lipgloss_style_render, [:uint64, :string], :pointer

    # Style text formatting
    attach_function :lipgloss_style_bold, [:uint64, :int], :uint64
    attach_function :lipgloss_style_italic, [:uint64, :int], :uint64
    attach_function :lipgloss_style_underline, [:uint64, :int], :uint64
    attach_function :lipgloss_style_strikethrough, [:uint64, :int], :uint64
    attach_function :lipgloss_style_reverse, [:uint64, :int], :uint64
    attach_function :lipgloss_style_blink, [:uint64, :int], :uint64
    attach_function :lipgloss_style_faint, [:uint64, :int], :uint64

    # Style colors
    attach_function :lipgloss_style_foreground, [:uint64, :string], :uint64
    attach_function :lipgloss_style_background, [:uint64, :string], :uint64
    attach_function :lipgloss_style_foreground_adaptive, [:uint64, :string, :string], :uint64
    attach_function :lipgloss_style_background_adaptive, [:uint64, :string, :string], :uint64
    attach_function :lipgloss_style_foreground_complete, [:uint64, :string, :string, :string], :uint64
    attach_function :lipgloss_style_background_complete, [:uint64, :string, :string, :string], :uint64
    attach_function :lipgloss_style_foreground_complete_adaptive, [:uint64, :string, :string, :string, :string, :string, :string], :uint64
    attach_function :lipgloss_style_background_complete_adaptive, [:uint64, :string, :string, :string, :string, :string, :string], :uint64
    attach_function :lipgloss_style_margin_background, [:uint64, :string], :uint64

    # Style size
    attach_function :lipgloss_style_width, [:uint64, :int], :uint64
    attach_function :lipgloss_style_height, [:uint64, :int], :uint64
    attach_function :lipgloss_style_max_width, [:uint64, :int], :uint64
    attach_function :lipgloss_style_max_height, [:uint64, :int], :uint64

    # Style alignment
    attach_function :lipgloss_style_align, [:uint64, :pointer, :int], :uint64
    attach_function :lipgloss_style_align_horizontal, [:uint64, :double], :uint64
    attach_function :lipgloss_style_align_vertical, [:uint64, :double], :uint64

    # Style other
    attach_function :lipgloss_style_inline, [:uint64, :int], :uint64
    attach_function :lipgloss_style_tab_width, [:uint64, :int], :uint64
    attach_function :lipgloss_style_underline_spaces, [:uint64, :int], :uint64
    attach_function :lipgloss_style_strikethrough_spaces, [:uint64, :int], :uint64
    attach_function :lipgloss_style_set_string, [:uint64, :string], :uint64
    attach_function :lipgloss_style_inherit, [:uint64, :uint64], :uint64
    attach_function :lipgloss_style_string, [:uint64], :pointer

    # Style getters
    attach_function :lipgloss_style_get_bold, [:uint64], :int
    attach_function :lipgloss_style_get_italic, [:uint64], :int
    attach_function :lipgloss_style_get_underline, [:uint64], :int
    attach_function :lipgloss_style_get_strikethrough, [:uint64], :int
    attach_function :lipgloss_style_get_reverse, [:uint64], :int
    attach_function :lipgloss_style_get_blink, [:uint64], :int
    attach_function :lipgloss_style_get_faint, [:uint64], :int
    attach_function :lipgloss_style_get_foreground, [:uint64], :pointer
    attach_function :lipgloss_style_get_background, [:uint64], :pointer
    attach_function :lipgloss_style_get_width, [:uint64], :int
    attach_function :lipgloss_style_get_height, [:uint64], :int

    # Style spacing
    attach_function :lipgloss_style_padding, [:uint64, :pointer, :int], :uint64
    attach_function :lipgloss_style_padding_top, [:uint64, :int], :uint64
    attach_function :lipgloss_style_padding_right, [:uint64, :int], :uint64
    attach_function :lipgloss_style_padding_bottom, [:uint64, :int], :uint64
    attach_function :lipgloss_style_padding_left, [:uint64, :int], :uint64
    attach_function :lipgloss_style_margin, [:uint64, :pointer, :int], :uint64
    attach_function :lipgloss_style_margin_top, [:uint64, :int], :uint64
    attach_function :lipgloss_style_margin_right, [:uint64, :int], :uint64
    attach_function :lipgloss_style_margin_bottom, [:uint64, :int], :uint64
    attach_function :lipgloss_style_margin_left, [:uint64, :int], :uint64

    # Style border
    attach_function :lipgloss_style_border, [:uint64, :int, :pointer, :int], :uint64
    attach_function :lipgloss_style_border_style, [:uint64, :int], :uint64
    attach_function :lipgloss_style_border_custom, [:uint64, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string], :uint64
    attach_function :lipgloss_style_border_foreground, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_foreground_adaptive, [:uint64, :string, :string], :uint64
    attach_function :lipgloss_style_border_background, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_background_adaptive, [:uint64, :string, :string], :uint64
    attach_function :lipgloss_style_border_top, [:uint64, :int], :uint64
    attach_function :lipgloss_style_border_right, [:uint64, :int], :uint64
    attach_function :lipgloss_style_border_bottom, [:uint64, :int], :uint64
    attach_function :lipgloss_style_border_left, [:uint64, :int], :uint64
    attach_function :lipgloss_style_border_top_foreground, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_right_foreground, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_bottom_foreground, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_left_foreground, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_top_background, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_right_background, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_bottom_background, [:uint64, :string], :uint64
    attach_function :lipgloss_style_border_left_background, [:uint64, :string], :uint64

    # Style unset
    attach_function :lipgloss_style_unset_bold, [:uint64], :uint64
    attach_function :lipgloss_style_unset_italic, [:uint64], :uint64
    attach_function :lipgloss_style_unset_underline, [:uint64], :uint64
    attach_function :lipgloss_style_unset_strikethrough, [:uint64], :uint64
    attach_function :lipgloss_style_unset_reverse, [:uint64], :uint64
    attach_function :lipgloss_style_unset_blink, [:uint64], :uint64
    attach_function :lipgloss_style_unset_faint, [:uint64], :uint64
    attach_function :lipgloss_style_unset_foreground, [:uint64], :uint64
    attach_function :lipgloss_style_unset_background, [:uint64], :uint64
    attach_function :lipgloss_style_unset_width, [:uint64], :uint64
    attach_function :lipgloss_style_unset_height, [:uint64], :uint64
    attach_function :lipgloss_style_unset_padding_top, [:uint64], :uint64
    attach_function :lipgloss_style_unset_padding_right, [:uint64], :uint64
    attach_function :lipgloss_style_unset_padding_bottom, [:uint64], :uint64
    attach_function :lipgloss_style_unset_padding_left, [:uint64], :uint64
    attach_function :lipgloss_style_unset_margin_top, [:uint64], :uint64
    attach_function :lipgloss_style_unset_margin_right, [:uint64], :uint64
    attach_function :lipgloss_style_unset_margin_bottom, [:uint64], :uint64
    attach_function :lipgloss_style_unset_margin_left, [:uint64], :uint64
    attach_function :lipgloss_style_unset_border_style, [:uint64], :uint64
    attach_function :lipgloss_style_unset_inline, [:uint64], :uint64

    # Table
    attach_function :lipgloss_table_new, [], :uint64
    attach_function :lipgloss_table_free, [:uint64], :void
    attach_function :lipgloss_table_headers, [:uint64, :string], :uint64
    attach_function :lipgloss_table_row, [:uint64, :string], :uint64
    attach_function :lipgloss_table_rows, [:uint64, :string], :uint64
    attach_function :lipgloss_table_border, [:uint64, :int], :uint64
    attach_function :lipgloss_table_border_style, [:uint64, :uint64], :uint64
    attach_function :lipgloss_table_border_top, [:uint64, :int], :uint64
    attach_function :lipgloss_table_border_bottom, [:uint64, :int], :uint64
    attach_function :lipgloss_table_border_left, [:uint64, :int], :uint64
    attach_function :lipgloss_table_border_right, [:uint64, :int], :uint64
    attach_function :lipgloss_table_border_header, [:uint64, :int], :uint64
    attach_function :lipgloss_table_border_column, [:uint64, :int], :uint64
    attach_function :lipgloss_table_border_row, [:uint64, :int], :uint64
    attach_function :lipgloss_table_width, [:uint64, :int], :uint64
    attach_function :lipgloss_table_height, [:uint64, :int], :uint64
    attach_function :lipgloss_table_offset, [:uint64, :int], :uint64
    attach_function :lipgloss_table_wrap, [:uint64, :int], :uint64
    attach_function :lipgloss_table_clear_rows, [:uint64], :uint64
    attach_function :lipgloss_table_render, [:uint64], :pointer
    attach_function :lipgloss_table_style_func, [:uint64, :string], :uint64

    # List
    attach_function :lipgloss_list_new, [], :uint64
    attach_function :lipgloss_list_free, [:uint64], :void
    attach_function :lipgloss_list_item, [:uint64, :string], :uint64
    attach_function :lipgloss_list_item_list, [:uint64, :uint64], :uint64
    attach_function :lipgloss_list_items, [:uint64, :string], :uint64
    attach_function :lipgloss_list_enumerator, [:uint64, :int], :uint64
    attach_function :lipgloss_list_enumerator_style, [:uint64, :uint64], :uint64
    attach_function :lipgloss_list_item_style, [:uint64, :uint64], :uint64
    attach_function :lipgloss_list_render, [:uint64], :pointer

    # Tree
    attach_function :lipgloss_tree_new, [], :uint64
    attach_function :lipgloss_tree_root, [:string], :uint64
    attach_function :lipgloss_tree_free, [:uint64], :void
    attach_function :lipgloss_tree_set_root, [:uint64, :string], :uint64
    attach_function :lipgloss_tree_child, [:uint64, :string], :uint64
    attach_function :lipgloss_tree_child_tree, [:uint64, :uint64], :uint64
    attach_function :lipgloss_tree_children, [:uint64, :string], :uint64
    attach_function :lipgloss_tree_enumerator, [:uint64, :int], :uint64
    attach_function :lipgloss_tree_enumerator_style, [:uint64, :uint64], :uint64
    attach_function :lipgloss_tree_item_style, [:uint64, :uint64], :uint64
    attach_function :lipgloss_tree_root_style, [:uint64, :uint64], :uint64
    attach_function :lipgloss_tree_offset, [:uint64, :int, :int], :uint64
    attach_function :lipgloss_tree_render, [:uint64], :pointer

    # Color blending
    attach_function :lipgloss_color_blend_luv, [:string, :string, :double], :pointer
    attach_function :lipgloss_color_blend_rgb, [:string, :string, :double], :pointer
    attach_function :lipgloss_color_blend_hcl, [:string, :string, :double], :pointer
    attach_function :lipgloss_color_blends, [:string, :string, :int, :int], :pointer
    attach_function :lipgloss_color_grid, [:string, :string, :string, :string, :int, :int, :int], :pointer

    # Helper: read a Go-allocated C string, free it, return Ruby string
    def self.read_go_string(ptr)
      return nil if ptr.null?

      str = ptr.read_string.force_encoding("UTF-8")
      lipgloss_free(ptr)
      str
    end
  end

  # Border type constants for FFI symbol-to-int conversion
  BORDER_TYPES = {
    normal: 0, rounded: 1, thick: 2, double: 3, hidden: 4,
    block: 5, outer_half_block: 6, inner_half_block: 7, ascii: 8, markdown: 9
  }.freeze

  LIST_ENUMERATORS = {
    bullet: 0, arabic: 1, alphabet: 2, roman: 3, dash: 4, asterisk: 5
  }.freeze

  TREE_ENUMERATORS = { default: 0, rounded: 1 }.freeze

  # Module-level methods
  class << self
    def _join_horizontal(position, strings)
      ptr = FFI.lipgloss_join_horizontal(position.to_f, strings.to_json)
      FFI.read_go_string(ptr)
    end

    def _join_vertical(position, strings)
      ptr = FFI.lipgloss_join_vertical(position.to_f, strings.to_json)
      FFI.read_go_string(ptr)
    end

    def width(string)
      FFI.lipgloss_width(string)
    end

    def height(string)
      FFI.lipgloss_height(string)
    end

    def size(string)
      [FFI.lipgloss_width(string), FFI.lipgloss_height(string)]
    end

    def _place(width, height, horizontal, vertical, string, **opts)
      if opts.any?
        ws_chars = opts[:whitespace_chars] || ""
        ws_fg = opts[:whitespace_foreground]

        if ws_fg && ws_fg.respond_to?(:light) && ws_fg.respond_to?(:dark)
          ptr = FFI.lipgloss_place_with_whitespace_adaptive(
            width, height, horizontal.to_f, vertical.to_f, string,
            ws_chars.to_s, ws_fg.light.to_s, ws_fg.dark.to_s
          )
        else
          ptr = FFI.lipgloss_place_with_whitespace(
            width, height, horizontal.to_f, vertical.to_f, string,
            ws_chars.to_s, ws_fg.to_s
          )
        end
      else
        ptr = FFI.lipgloss_place(width, height, horizontal.to_f, vertical.to_f, string)
      end

      FFI.read_go_string(ptr)
    end

    def _place_horizontal(width, position, string)
      ptr = FFI.lipgloss_place_horizontal(width, position.to_f, string)
      FFI.read_go_string(ptr)
    end

    def _place_vertical(height, position, string)
      ptr = FFI.lipgloss_place_vertical(height, position.to_f, string)
      FFI.read_go_string(ptr)
    end

    def has_dark_background? # rubocop:disable Naming/PredicateName
      FFI.lipgloss_has_dark_background != 0
    end

    def upstream_version
      ptr = FFI.lipgloss_upstream_version
      FFI.read_go_string(ptr)
    end

    def version
      "lipgloss v#{VERSION} (upstream #{upstream_version}) [Go FFI]"
    end
  end

  # Style class backed by FFI
  class Style
    attr_reader :handle

    def initialize
      @handle = FFI.lipgloss_new_style
      define_invoke_free
    end

    def render(string)
      ptr = FFI.lipgloss_style_render(@handle, string)
      FFI.read_go_string(ptr)
    end

    # Text formatting
    %i[bold italic underline strikethrough reverse blink faint].each do |method|
      define_method(method) do |value|
        new_handle = FFI.send(:"lipgloss_style_#{method}", @handle, value ? 1 : 0)
        self.class.wrap(new_handle)
      end
    end

    # Color methods
    def foreground(color)
      self.class.wrap(apply_color(:foreground, color))
    end

    def background(color)
      self.class.wrap(apply_color(:background, color))
    end

    def margin_background(color)
      self.class.wrap(FFI.lipgloss_style_margin_background(@handle, color.to_s))
    end

    # Size methods
    %i[width height max_width max_height].each do |method|
      define_method(method) do |value|
        new_handle = FFI.send(:"lipgloss_style_#{method}", @handle, value)
        self.class.wrap(new_handle)
      end
    end

    # Alignment
    def _align(*positions)
      ptr = ::FFI::MemoryPointer.new(:double, positions.length)
      ptr.write_array_of_double(positions.map(&:to_f))
      new_handle = Lipgloss::FFI.lipgloss_style_align(@handle, ptr, positions.length)
      self.class.wrap(new_handle)
    end

    def _align_horizontal(position)
      self.class.wrap(FFI.lipgloss_style_align_horizontal(@handle, position.to_f))
    end

    def _align_vertical(position)
      self.class.wrap(FFI.lipgloss_style_align_vertical(@handle, position.to_f))
    end

    # Other style methods
    def inline(value)
      self.class.wrap(FFI.lipgloss_style_inline(@handle, value ? 1 : 0))
    end

    def tab_width(width)
      self.class.wrap(FFI.lipgloss_style_tab_width(@handle, width))
    end

    def underline_spaces(value)
      self.class.wrap(FFI.lipgloss_style_underline_spaces(@handle, value ? 1 : 0))
    end

    def strikethrough_spaces(value)
      self.class.wrap(FFI.lipgloss_style_strikethrough_spaces(@handle, value ? 1 : 0))
    end

    def set_string(string)
      self.class.wrap(FFI.lipgloss_style_set_string(@handle, string))
    end

    def inherit(other)
      self.class.wrap(FFI.lipgloss_style_inherit(@handle, other.handle))
    end

    def to_s
      ptr = FFI.lipgloss_style_string(@handle)
      FFI.read_go_string(ptr)
    end

    # Getters
    %i[bold italic underline strikethrough reverse blink faint].each do |method|
      define_method(:"#{method}?") do
        FFI.send(:"lipgloss_style_get_#{method}", @handle) != 0
      end
    end

    def get_foreground
      ptr = FFI.lipgloss_style_get_foreground(@handle)
      result = FFI.read_go_string(ptr)
      result&.empty? ? nil : result
    end

    def get_background
      ptr = FFI.lipgloss_style_get_background(@handle)
      result = FFI.read_go_string(ptr)
      result&.empty? ? nil : result
    end

    def get_width
      FFI.lipgloss_style_get_width(@handle)
    end

    def get_height
      FFI.lipgloss_style_get_height(@handle)
    end

    # Spacing methods
    def padding(*values)
      ptr = ::FFI::MemoryPointer.new(:int, values.length)
      ptr.write_array_of_int(values)
      self.class.wrap(Lipgloss::FFI.lipgloss_style_padding(@handle, ptr, values.length))
    end

    %i[padding_top padding_right padding_bottom padding_left
       margin_top margin_right margin_bottom margin_left].each do |method|
      define_method(method) do |value|
        self.class.wrap(FFI.send(:"lipgloss_style_#{method}", @handle, value))
      end
    end

    def margin(*values)
      ptr = ::FFI::MemoryPointer.new(:int, values.length)
      ptr.write_array_of_int(values)
      self.class.wrap(Lipgloss::FFI.lipgloss_style_margin(@handle, ptr, values.length))
    end

    # Border methods
    def border(border_sym, *sides)
      border_type = BORDER_TYPES.fetch(border_sym, 0)
      if sides.empty?
        self.class.wrap(FFI.lipgloss_style_border(@handle, border_type, nil, 0))
      else
        ptr = ::FFI::MemoryPointer.new(:int, sides.length)
        ptr.write_array_of_int(sides.map { |s| s ? 1 : 0 })
        self.class.wrap(Lipgloss::FFI.lipgloss_style_border(@handle, border_type, ptr, sides.length))
      end
    end

    def border_style(border_sym)
      self.class.wrap(FFI.lipgloss_style_border_style(@handle, BORDER_TYPES.fetch(border_sym, 0)))
    end

    def border_foreground(color)
      if color.respond_to?(:light) && color.respond_to?(:dark)
        self.class.wrap(FFI.lipgloss_style_border_foreground_adaptive(@handle, color.light.to_s, color.dark.to_s))
      else
        self.class.wrap(FFI.lipgloss_style_border_foreground(@handle, color.to_s))
      end
    end

    def border_background(color)
      if color.respond_to?(:light) && color.respond_to?(:dark)
        self.class.wrap(FFI.lipgloss_style_border_background_adaptive(@handle, color.light.to_s, color.dark.to_s))
      else
        self.class.wrap(FFI.lipgloss_style_border_background(@handle, color.to_s))
      end
    end

    %i[border_top border_right border_bottom border_left].each do |method|
      define_method(method) do |value|
        self.class.wrap(FFI.send(:"lipgloss_style_#{method}", @handle, value ? 1 : 0))
      end
    end

    %i[border_top_foreground border_right_foreground border_bottom_foreground border_left_foreground
       border_top_background border_right_background border_bottom_background border_left_background].each do |method|
      define_method(method) do |color|
        self.class.wrap(FFI.send(:"lipgloss_style_#{method}", @handle, color.to_s))
      end
    end

    def border_custom(top: "", bottom: "", left: "", right: "",
                      top_left: "", top_right: "", bottom_left: "", bottom_right: "",
                      middle_left: "", middle_right: "", middle: "",
                      middle_top: "", middle_bottom: "")
      self.class.wrap(FFI.lipgloss_style_border_custom(
        @handle, top, bottom, left, right, top_left, top_right,
        bottom_left, bottom_right, middle_left, middle_right,
        middle, middle_top, middle_bottom
      ))
    end

    # Unset methods
    %i[bold italic underline strikethrough reverse blink faint
       foreground background width height
       padding_top padding_right padding_bottom padding_left
       margin_top margin_right margin_bottom margin_left
       border_style inline].each do |method|
      define_method(:"unset_#{method}") do
        self.class.wrap(FFI.send(:"lipgloss_style_unset_#{method}", @handle))
      end
    end

    # @api private
    def self.wrap(handle)
      obj = allocate
      obj.instance_variable_set(:@handle, handle)
      obj.send(:define_invoke_free)
      obj
    end

    private

    def define_invoke_free
      handle = @handle
      ObjectSpace.define_finalizer(self, self.class.invoke_free(handle))
    end

    def self.invoke_free(handle)
      proc { FFI.lipgloss_free_style(handle) if handle != 0 }
    end

    def apply_color(method, color)
      if color.respond_to?(:light) && color.respond_to?(:dark)
        light = color.light
        dark = color.dark

        if [light, dark].all? { |c| c.respond_to?(:true_color) && c.respond_to?(:ansi256) && c.respond_to?(:ansi) }
          return FFI.send(:"lipgloss_style_#{method}_complete_adaptive",
            @handle,
            light.true_color.to_s, light.ansi256.to_s, light.ansi.to_s,
            dark.true_color.to_s, dark.ansi256.to_s, dark.ansi.to_s)
        end

        return FFI.send(:"lipgloss_style_#{method}_adaptive", @handle, light.to_s, dark.to_s)
      end

      if color.respond_to?(:true_color) && color.respond_to?(:ansi256) && color.respond_to?(:ansi)
        return FFI.send(:"lipgloss_style_#{method}_complete",
          @handle, color.true_color.to_s, color.ansi256.to_s, color.ansi.to_s)
      end

      FFI.send(:"lipgloss_style_#{method}", @handle, color.to_s)
    end
  end

  # Table class backed by FFI
  class Table
    attr_reader :handle

    def initialize
      @handle = FFI.lipgloss_table_new
      define_invoke_free
    end

    def headers(headers)
      self.class.wrap(FFI.lipgloss_table_headers(@handle, headers.to_json))
    end

    def row(row)
      self.class.wrap(FFI.lipgloss_table_row(@handle, row.to_json))
    end

    def rows(rows)
      self.class.wrap(FFI.lipgloss_table_rows(@handle, rows.to_json))
    end

    def border(border_sym)
      self.class.wrap(FFI.lipgloss_table_border(@handle, BORDER_TYPES.fetch(border_sym, 0)))
    end

    def border_style(style)
      self.class.wrap(FFI.lipgloss_table_border_style(@handle, style.handle))
    end

    %i[border_top border_bottom border_left border_right border_header border_column border_row].each do |method|
      define_method(method) do |value|
        self.class.wrap(FFI.send(:"lipgloss_table_#{method}", @handle, value ? 1 : 0))
      end
    end

    %i[width height offset].each do |method|
      define_method(method) do |value|
        self.class.wrap(FFI.send(:"lipgloss_table_#{method}", @handle, value))
      end
    end

    def wrap(value)
      self.class.wrap(FFI.lipgloss_table_wrap(@handle, value ? 1 : 0))
    end

    def clear_rows
      self.class.wrap(FFI.lipgloss_table_clear_rows(@handle))
    end

    def _style_func_map(style_map)
      json_hash = {}
      style_map.each { |key, style| json_hash[key] = style.handle }
      self.class.wrap(FFI.lipgloss_table_style_func(@handle, json_hash.to_json))
    end

    def render
      ptr = FFI.lipgloss_table_render(@handle)
      FFI.read_go_string(ptr)
    end

    alias_method :to_s, :render

    def self.wrap(handle)
      obj = allocate
      obj.instance_variable_set(:@handle, handle)
      obj.send(:define_invoke_free)
      obj
    end

    private

    def define_invoke_free
      handle = @handle
      ObjectSpace.define_finalizer(self, self.class.invoke_free(handle))
    end

    def self.invoke_free(handle)
      proc { FFI.lipgloss_table_free(handle) if handle != 0 }
    end
  end

  # List class backed by FFI
  class List
    attr_reader :handle

    def initialize(*items)
      @handle = FFI.lipgloss_list_new
      @handle = FFI.lipgloss_list_items(@handle, items.to_json) if items.any?
      define_invoke_free
    end

    def item(item)
      if item.is_a?(List)
        self.class.wrap(FFI.lipgloss_list_item_list(@handle, item.handle))
      else
        self.class.wrap(FFI.lipgloss_list_item(@handle, item.to_s))
      end
    end

    def items(items)
      self.class.wrap(FFI.lipgloss_list_items(@handle, items.to_json))
    end

    def enumerator(enum_symbol)
      self.class.wrap(FFI.lipgloss_list_enumerator(@handle, LIST_ENUMERATORS.fetch(enum_symbol, 0)))
    end

    def enumerator_style(style)
      self.class.wrap(FFI.lipgloss_list_enumerator_style(@handle, style.handle))
    end

    def item_style(style)
      self.class.wrap(FFI.lipgloss_list_item_style(@handle, style.handle))
    end

    def render
      ptr = FFI.lipgloss_list_render(@handle)
      FFI.read_go_string(ptr)
    end

    alias_method :to_s, :render

    def self.wrap(handle)
      obj = allocate
      obj.instance_variable_set(:@handle, handle)
      obj.send(:define_invoke_free)
      obj
    end

    private

    def define_invoke_free
      handle = @handle
      ObjectSpace.define_finalizer(self, self.class.invoke_free(handle))
    end

    def self.invoke_free(handle)
      proc { FFI.lipgloss_list_free(handle) if handle != 0 }
    end
  end

  # Tree class backed by FFI
  class Tree
    attr_reader :handle

    def initialize(root = nil)
      @handle = FFI.lipgloss_tree_new
      @handle = FFI.lipgloss_tree_set_root(@handle, root) if root
      define_invoke_free
    end

    def self.root(root)
      handle = FFI.lipgloss_tree_root(root)
      wrap(handle)
    end

    def root=(root)
      self.class.wrap(FFI.lipgloss_tree_set_root(@handle, root))
    end

    def child(*children)
      result_handle = @handle
      children.each do |child|
        if child.is_a?(Tree)
          result_handle = FFI.lipgloss_tree_child_tree(result_handle, child.handle)
        else
          result_handle = FFI.lipgloss_tree_child(result_handle, child.to_s)
        end
      end
      self.class.wrap(result_handle)
    end

    def children(children)
      self.class.wrap(FFI.lipgloss_tree_children(@handle, children.to_json))
    end

    def enumerator(enum_symbol)
      self.class.wrap(FFI.lipgloss_tree_enumerator(@handle, TREE_ENUMERATORS.fetch(enum_symbol, 0)))
    end

    def enumerator_style(style)
      self.class.wrap(FFI.lipgloss_tree_enumerator_style(@handle, style.handle))
    end

    def item_style(style)
      self.class.wrap(FFI.lipgloss_tree_item_style(@handle, style.handle))
    end

    def root_style(style)
      self.class.wrap(FFI.lipgloss_tree_root_style(@handle, style.handle))
    end

    def offset(start, end_pos)
      self.class.wrap(FFI.lipgloss_tree_offset(@handle, start, end_pos))
    end

    def render
      ptr = FFI.lipgloss_tree_render(@handle)
      FFI.read_go_string(ptr)
    end

    alias_method :to_s, :render

    def self.wrap(handle)
      obj = allocate
      obj.instance_variable_set(:@handle, handle)
      obj.send(:define_invoke_free)
      obj
    end

    private

    def define_invoke_free
      handle = @handle
      ObjectSpace.define_finalizer(self, self.class.invoke_free(handle))
    end

    def self.invoke_free(handle)
      proc { FFI.lipgloss_tree_free(handle) if handle != 0 }
    end
  end

  # ColorBlend module backed by FFI
  module ColorBlend
    LUV = :luv
    RGB = :rgb
    HCL = :hcl

    BLEND_MODES = { luv: 0, rgb: 1, hcl: 2 }.freeze

    class << self
      def blend(c1, c2, t, mode: nil)
        mode_int = BLEND_MODES.fetch(mode, 0)
        case mode_int
        when 1
          ptr = FFI.lipgloss_color_blend_rgb(c1, c2, t.to_f)
        when 2
          ptr = FFI.lipgloss_color_blend_hcl(c1, c2, t.to_f)
        else
          ptr = FFI.lipgloss_color_blend_luv(c1, c2, t.to_f)
        end
        FFI.read_go_string(ptr)
      end

      def blend_luv(c1, c2, t)
        FFI.read_go_string(FFI.lipgloss_color_blend_luv(c1, c2, t.to_f))
      end

      def blend_rgb(c1, c2, t)
        FFI.read_go_string(FFI.lipgloss_color_blend_rgb(c1, c2, t.to_f))
      end

      def blend_hcl(c1, c2, t)
        FFI.read_go_string(FFI.lipgloss_color_blend_hcl(c1, c2, t.to_f))
      end

      def blends(c1, c2, steps, mode: nil)
        mode_int = BLEND_MODES.fetch(mode, 0)
        ptr = FFI.lipgloss_color_blends(c1, c2, steps, mode_int)
        JSON.parse(FFI.read_go_string(ptr))
      end

      def grid(x0y0, x1y0, x0y1, x1y1, x_steps, y_steps, mode: nil)
        mode_int = BLEND_MODES.fetch(mode, 0)
        ptr = FFI.lipgloss_color_grid(x0y0, x1y0, x0y1, x1y1, x_steps, y_steps, mode_int)
        JSON.parse(FFI.read_go_string(ptr))
      end
    end
  end
end
