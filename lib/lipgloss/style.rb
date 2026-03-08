# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  class Style
    include Immutable

    # Default tab width
    DEFAULT_TAB_WIDTH = 4

    # All styleable properties with their defaults
    PROPERTIES = {
      bold: false, italic: false, underline: false, strikethrough: false,
      reverse: false, blink: false, faint: false,
      foreground: nil, background: nil,
      width: 0, height: 0, max_width: 0, max_height: 0,
      align_horizontal: 0.0, align_vertical: 0.0,
      padding_top: 0, padding_right: 0, padding_bottom: 0, padding_left: 0,
      margin_top: 0, margin_right: 0, margin_bottom: 0, margin_left: 0,
      border_type: nil, border_top: false, border_right: false, border_bottom: false, border_left: false,
      border_top_fg: nil, border_right_fg: nil, border_bottom_fg: nil, border_left_fg: nil,
      border_top_bg: nil, border_right_bg: nil, border_bottom_bg: nil, border_left_bg: nil,
      inline: false, tab_width: DEFAULT_TAB_WIDTH,
      string_value: nil
    }.freeze

    def initialize
      @props = PROPERTIES.dup
      @set = {}
    end

    # ---- Render pipeline ----

    def render(text = nil)
      str = (text || @props[:string_value] || "").to_s

      str = convert_tabs(str)
      str = apply_max_width(str) if @set[:max_width] && @props[:max_width].positive?
      str = apply_width_and_alignment(str)
      str = apply_height_and_valign(str)
      str = apply_padding(str)
      str = apply_border(str)
      str = apply_margins(str)
      str = apply_inline(str) if @props[:inline]
      apply_ansi_styles(str)
    end

    def to_s
      render(@props[:string_value])
    end

    # ---- Text formatting setters ----

    [:bold, :italic, :underline, :strikethrough, :reverse, :blink, :faint].each do |prop|
      define_method(prop) do |value|
        with(prop, value)
      end

      define_method(:"#{prop}?") do
        @props[prop]
      end
    end

    # ---- Color setters ----

    def foreground(color)
      with(:foreground, color)
    end

    def background(color)
      with(:background, color)
    end

    # ---- Color getters ----

    def get_foreground
      c = @props[:foreground]
      if c.is_a?(String)
        c.empty? ? nil : c
      else
        c&.to_s
      end
    end

    def get_background
      c = @props[:background]
      if c.is_a?(String)
        c.empty? ? nil : c
      else
        c&.to_s
      end
    end

    # ---- Size setters ----

    def width(value)
      with(:width, value)
    end

    def height(value)
      with(:height, value)
    end

    def max_width(value)
      with(:max_width, value)
    end

    def max_height(value)
      with(:max_height, value)
    end

    def get_width
      @props[:width]
    end

    def get_height
      @props[:height]
    end

    # ---- Alignment ----

    def align(*positions)
      result = self
      result = result._align_horizontal(Lipgloss::Position.resolve(positions[0])) if positions.length >= 1
      result = result._align_vertical(Lipgloss::Position.resolve(positions[1])) if positions.length >= 2
      result
    end

    def align_horizontal(position)
      _align_horizontal(Lipgloss::Position.resolve(position))
    end

    def align_vertical(position)
      _align_vertical(Lipgloss::Position.resolve(position))
    end

    def _align_horizontal(position)
      with(:align_horizontal, position.to_f)
    end

    def _align_vertical(position)
      with(:align_vertical, position.to_f)
    end

    # ---- Spacing ----

    def padding(*values)
      top, right, bottom, left = expand_shorthand(values)
      dup_with do |s|
        s.set_prop(:padding_top, top)
        s.set_prop(:padding_right, right)
        s.set_prop(:padding_bottom, bottom)
        s.set_prop(:padding_left, left)
      end
    end

    [:padding_top, :padding_right, :padding_bottom, :padding_left].each do |prop|
      define_method(prop) do |value|
        with(prop, value)
      end
    end

    def margin(*values)
      top, right, bottom, left = expand_shorthand(values)
      dup_with do |s|
        s.set_prop(:margin_top, top)
        s.set_prop(:margin_right, right)
        s.set_prop(:margin_bottom, bottom)
        s.set_prop(:margin_left, left)
      end
    end

    [:margin_top, :margin_right, :margin_bottom, :margin_left].each do |prop|
      define_method(prop) do |value|
        with(prop, value)
      end
    end

    # ---- Border ----

    def border(border_sym, *sides)
      dup_with do |s|
        s.set_prop(:border_type, border_sym)
        if sides.empty?
          s.set_prop(:border_top, true)
          s.set_prop(:border_right, true)
          s.set_prop(:border_bottom, true)
          s.set_prop(:border_left, true)
        else
          s.set_prop(:border_top, sides[0] || false) if sides.length.positive?
          s.set_prop(:border_right, sides[1] || false) if sides.length > 1
          s.set_prop(:border_bottom, sides[2] || false) if sides.length > 2
          s.set_prop(:border_left, sides[3] || false) if sides.length > 3
        end
      end
    end

    def border_style(border_sym)
      with(:border_type, border_sym)
    end

    def border_custom(top: "", bottom: "", left: "", right: "",
                      top_left: "", top_right: "", bottom_left: "", bottom_right: "",
                      middle_left: "", middle_right: "", middle: "",
                      middle_top: "", middle_bottom: "")
      custom = {
        top: top, bottom: bottom, left: left, right: right,
        top_left: top_left, top_right: top_right,
        bottom_left: bottom_left, bottom_right: bottom_right,
        middle_left: middle_left, middle_right: middle_right,
        middle: middle, middle_top: middle_top, middle_bottom: middle_bottom
      }

      # Determine which sides are enabled
      # Top/bottom are enabled if their char is non-empty
      # Left/right: if char is non-empty they are fully enabled;
      # if char is empty but top or bottom is enabled, we still need
      # a space column for alignment
      has_top = !top.empty?
      has_bottom = !bottom.empty?
      has_left = !left.empty?
      has_right = !right.empty?

      # When left/right chars are empty but top/bottom are present,
      # we need space columns for alignment. We handle this by always
      # enabling left/right when top or bottom is present, using space
      # as the side character.
      needs_side_space = (has_top || has_bottom) && (!has_left || !has_right)

      if needs_side_space
        custom = custom.dup
        custom[:left] = " " unless has_left
        custom[:right] = " " unless has_right
        # Also set corner chars to space when sides use space
        unless has_left
          custom[:top_left] = " " if custom[:top_left].empty?
          custom[:bottom_left] = " " if custom[:bottom_left].empty?
        end
        unless has_right
          custom[:top_right] = " " if custom[:top_right].empty?
          custom[:bottom_right] = " " if custom[:bottom_right].empty?
        end
      end

      dup_with do |s|
        s.set_prop(:border_type, custom)
        s.set_prop(:border_top, has_top)
        s.set_prop(:border_right, has_right || needs_side_space)
        s.set_prop(:border_bottom, has_bottom)
        s.set_prop(:border_left, has_left || needs_side_space)
      end
    end

    [:border_top, :border_right, :border_bottom, :border_left].each do |prop|
      define_method(prop) do |value|
        with(prop, value)
      end
    end

    def border_foreground(color)
      dup_with do |s|
        s.set_prop(:border_top_fg, color)
        s.set_prop(:border_right_fg, color)
        s.set_prop(:border_bottom_fg, color)
        s.set_prop(:border_left_fg, color)
      end
    end

    def border_background(color)
      dup_with do |s|
        s.set_prop(:border_top_bg, color)
        s.set_prop(:border_right_bg, color)
        s.set_prop(:border_bottom_bg, color)
        s.set_prop(:border_left_bg, color)
      end
    end

    [:border_top_foreground, :border_right_foreground, :border_bottom_foreground, :border_left_foreground].each do |method|
      prop = method.to_s.sub("foreground", "fg").to_sym
      define_method(method) do |color|
        with(prop, color)
      end
    end

    [:border_top_background, :border_right_background, :border_bottom_background, :border_left_background].each do |method|
      prop = method.to_s.sub("background", "bg").to_sym
      define_method(method) do |color|
        with(prop, color)
      end
    end

    # ---- Other ----

    def inline(value)
      with(:inline, value)
    end

    def tab_width(value)
      with(:tab_width, value)
    end

    def set_string(string)
      with(:string_value, string)
    end

    # ---- Inherit ----

    def inherit(other)
      dup_with do |s|
        other.instance_variable_get(:@set).each_key do |key|
          s.set_prop(key, other.instance_variable_get(:@props)[key]) unless s.instance_variable_get(:@set).key?(key)
        end
      end
    end

    # ---- Unset ----

    [:bold, :italic, :underline, :strikethrough, :reverse, :blink, :faint, :foreground, :background, :width, :height, :padding_top, :padding_right, :padding_bottom, :padding_left, :margin_top, :margin_right, :margin_bottom, :margin_left, :border_style, :inline].each do |prop|
      actual_prop = prop == :border_style ? :border_type : prop
      define_method(:"unset_#{prop}") do
        dup_with do |s|
          s.unset_prop(actual_prop)
        end
      end
    end

    protected

    def set_prop(key, value)
      @props[key] = value
      @set[key] = true
    end

    def unset_prop(key)
      @props[key] = PROPERTIES[key]
      @set.delete(key)
    end

    private

    def with(prop, value)
      dup_with { |s| s.set_prop(prop, value) }
    end

    # CSS-style shorthand expansion
    def expand_shorthand(values)
      case values.length
      when 1 then [values[0]] * 4
      when 2 then [values[0], values[1], values[0], values[1]]
      when 3 then [values[0], values[1], values[2], values[1]]
      when 4 then values
      else raise ArgumentError, "Expected 1-4 values, got #{values.length}"
      end
    end

    # ---- Render pipeline steps ----

    def convert_tabs(str)
      tw = @props[:tab_width]
      return str if tw.negative?
      return str.gsub("\t", "") if tw.zero?

      str.gsub("\t", " " * tw)
    end

    def apply_max_width(str)
      max_w = @props[:max_width]
      return str if max_w <= 0

      lines = str.split("\n", -1)
      result = []
      lines.each do |line|
        if visible_width(line) <= max_w
          result << line
        else
          result.concat(word_wrap_line(line, max_w))
        end
      end
      result.join("\n")
    end

    def word_wrap_line(line, max_w)
      result = []
      words = line.split(/( +)/)
      current_line = ""
      current_width = 0

      words.each do |word|
        word_width = visible_width(word)

        if current_width + word_width <= max_w
          current_line += word
          current_width += word_width
        elsif current_width.zero?
          # Single word longer than max_width, force break character by character
          word.each_char do |ch|
            ch_width = visible_width(ch)
            if current_width + ch_width > max_w && current_width.positive?
              result << current_line
              current_line = ch
              current_width = ch_width
            else
              current_line += ch
              current_width += ch_width
            end
          end
        else
          result << current_line
          word = word.lstrip
          current_line = word
          current_width = visible_width(word)
        end
      end
      result << current_line unless current_line.empty?
      result
    end

    def apply_width_and_alignment(str)
      w = @props[:width]
      return str if !@set[:width] || w <= 0

      h_align = @props[:align_horizontal]
      lines = str.split("\n", -1)
      lines = [""] if lines.empty?
      lines.map { |line| align_line_horizontal(line, w, h_align) }.join("\n")
    end

    def apply_height_and_valign(str)
      h = @props[:height]
      return str if !@set[:height] || h <= 0

      lines = str.split("\n", -1)
      content_width = lines.map { |l| visible_width(l) }.max || 0
      v_align = @props[:align_vertical]

      if lines.length < h
        gap = h - lines.length
        top = (gap * v_align).floor
        bottom = gap - top

        blank = " " * content_width
        lines = Array.new(top, blank) + lines + Array.new(bottom, blank)
      end

      lines.join("\n")
    end

    def align_line_horizontal(line, target_width, align)
      line_width = visible_width(line)
      return line if line_width >= target_width

      gap = target_width - line_width
      left = (gap * align).floor
      right = gap - left
      (" " * left) + line + (" " * right)
    end

    def apply_padding(str)
      pt = @props[:padding_top]
      pr = @props[:padding_right]
      pb = @props[:padding_bottom]
      pl = @props[:padding_left]

      return str if pt.zero? && pr.zero? && pb.zero? && pl.zero?

      lines = str.split("\n", -1)

      # Add left/right padding
      if pl.positive? || pr.positive?
        lines = lines.map do |line|
          (" " * pl) + line + (" " * pr)
        end
      end

      # Calculate content width after horizontal padding
      content_width = lines.map { |l| visible_width(l) }.max || 0

      # Add top padding
      if pt.positive?
        blank = " " * content_width
        lines = Array.new(pt, blank) + lines
      end

      # Add bottom padding
      if pb.positive?
        blank = " " * content_width
        lines += Array.new(pb, blank)
      end

      lines.join("\n")
    end

    def apply_border(str)
      bt = @props[:border_type]
      return str unless bt

      has_top = @props[:border_top]
      has_right = @props[:border_right]
      has_bottom = @props[:border_bottom]
      has_left = @props[:border_left]

      return str unless has_top || has_right || has_bottom || has_left

      chars = Lipgloss::Border.chars_for(bt)
      lines = str.split("\n", -1)

      # Calculate content width
      content_width = lines.map { |l| visible_width(l) }.max || 0

      result = []

      # Top border
      if has_top
        top_line = ""
        top_line += colorize_border_char(has_left ? chars[:top_left] : "", :top)
        top_line += colorize_border_char(chars[:top] * content_width, :top)
        top_line += colorize_border_char(has_right ? chars[:top_right] : "", :top)
        result << top_line
      end

      # Content lines with side borders
      lines.each do |line|
        line_width = visible_width(line)
        padded_line = line + (" " * (content_width - line_width))
        bordered = ""
        bordered += colorize_border_char(chars[:left], :left) if has_left
        bordered += padded_line
        bordered += colorize_border_char(chars[:right], :right) if has_right
        result << bordered
      end

      # Bottom border
      if has_bottom
        bottom_line = ""
        bottom_line += colorize_border_char(has_left ? chars[:bottom_left] : "", :bottom)
        bottom_line += colorize_border_char(chars[:bottom] * content_width, :bottom)
        bottom_line += colorize_border_char(has_right ? chars[:bottom_right] : "", :bottom)
        result << bottom_line
      end

      result.join("\n")
    end

    def colorize_border_char(char, side)
      return char if char.empty?

      fg_prop = :"border_#{side}_fg"
      bg_prop = :"border_#{side}_bg"
      fg = @props[fg_prop]
      bg = @props[bg_prop]

      codes = []
      codes << Lipgloss::Color.to_ansi_fg(fg) if fg
      codes << Lipgloss::Color.to_ansi_bg(bg) if bg
      codes.reject!(&:empty?)

      if codes.any?
        Lipgloss::Ansi.apply(char, codes)
      else
        char
      end
    end

    def apply_margins(str)
      mt = @props[:margin_top]
      mr = @props[:margin_right]
      mb = @props[:margin_bottom]
      ml = @props[:margin_left]

      return str if mt.zero? && mr.zero? && mb.zero? && ml.zero?

      lines = str.split("\n", -1)

      # Add left/right margins
      if ml.positive? || mr.positive?
        lines = lines.map do |line|
          (" " * ml) + line + (" " * mr)
        end
      end

      # Add top margins
      content_width = lines.map { |l| visible_width(l) }.max || 0
      if mt.positive?
        blank = " " * content_width
        lines = Array.new(mt, blank) + lines
      end

      # Add bottom margins
      if mb.positive?
        blank = " " * content_width
        lines += Array.new(mb, blank)
      end

      lines.join("\n")
    end

    def apply_inline(str)
      str.gsub("\n", "")
    end

    def apply_ansi_styles(str)
      codes = build_ansi_codes
      return str if codes.empty?

      Lipgloss::Ansi.apply_per_line(str, codes)
    end

    def build_ansi_codes
      codes = []
      codes << Lipgloss::Ansi::BOLD if @props[:bold]
      codes << Lipgloss::Ansi::FAINT if @props[:faint]
      codes << Lipgloss::Ansi::ITALIC if @props[:italic]
      codes << Lipgloss::Ansi::UNDERLINE if @props[:underline]
      codes << Lipgloss::Ansi::BLINK if @props[:blink]
      codes << Lipgloss::Ansi::REVERSE if @props[:reverse]
      codes << Lipgloss::Ansi::STRIKETHROUGH if @props[:strikethrough]

      if @props[:foreground]
        fg = Lipgloss::Color.to_ansi_fg(@props[:foreground])
        codes << fg unless fg.empty?
      end

      if @props[:background]
        bg = Lipgloss::Color.to_ansi_bg(@props[:background])
        codes << bg unless bg.empty?
      end

      codes
    end

    # Calculate visible width of a string (strips ANSI, handles Unicode)
    def visible_width(str)
      Lipgloss::Ansi.width(str)
    end
  end
end
