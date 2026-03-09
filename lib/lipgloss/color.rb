# frozen_string_literal: true
# rbs_inline: enabled

module Lipgloss
  # @rbs!
  #   type adaptive_color_hash = { light: String, dark: String }
  #   type complete_color_hash = { true_color: String, ansi256: String, ansi: String }
  #   type complete_adaptive_color_hash = { light: complete_color_hash, dark: complete_color_hash }

  module ANSIColor
    # @rbs!
    #   type ansi_color_symbol = :black | :red | :green | :yellow | :blue | :magenta | :cyan | :white | :bright_black | :bright_red | :bright_green | :bright_yellow | :bright_blue | :bright_magenta | :bright_cyan | :bright_white
    #   type ansi_color_value = ansi_color_symbol | Symbol | String | Integer

    COLORS = {
      black: "0",
      red: "1",
      green: "2",
      yellow: "3",
      blue: "4",
      magenta: "5",
      cyan: "6",
      white: "7",
      bright_black: "8",
      bright_red: "9",
      bright_green: "10",
      bright_yellow: "11",
      bright_blue: "12",
      bright_magenta: "13",
      bright_cyan: "14",
      bright_white: "15"
    }.freeze #: Hash[Symbol, String]

    # @rbs value: ansi_color_value
    # @rbs return: String
    def self.resolve(value)
      case value
      when Symbol then COLORS.fetch(value) { raise ArgumentError, "Unknown ANSI color: #{value.inspect}" }
      when String then value
      when Integer then value.to_s
      else raise ArgumentError, "ANSI color must be a Symbol, String, or Integer, got #{value.class}"
      end
    end
  end

  # Adaptive color that changes based on terminal background
  #
  # @example
  #   color = Lipgloss::AdaptiveColor.new(light: "#000000", dark: "#FFFFFF")
  #   style = Lipgloss::Style.new.foreground(color)
  class AdaptiveColor
    # @rbs @light: String
    # @rbs @dark: String

    attr_reader :light #: String
    attr_reader :dark #: String

    # @rbs light: String -- color to use on light backgrounds
    # @rbs dark: String -- color to use on dark backgrounds
    # @rbs return: void
    def initialize(light:, dark:)
      @light = light
      @dark = dark
    end

    # @rbs return: adaptive_color_hash
    def to_h
      { light: @light, dark: @dark }
    end
  end

  # Complete color with explicit values for each color profile
  #
  # @example
  #   color = Lipgloss::CompleteColor.new(
  #     true_color: "#0000FF",
  #     ansi256: 21,
  #     ansi: :blue
  #   )
  class CompleteColor
    # @rbs @true_color: String
    # @rbs @ansi256: String
    # @rbs @ansi: String

    attr_reader :true_color #: String
    attr_reader :ansi256 #: String
    attr_reader :ansi #: String

    # @rbs true_color: String -- 24-bit color (e.g., "#0000FF")
    # @rbs ansi256: ANSIColor::ansi_color_value -- 8-bit ANSI color (0-255, or symbol for 0-15)
    # @rbs ansi: ANSIColor::ansi_color_value -- 4-bit ANSI color (:red, :blue, etc., or 0-15)
    # @rbs return: void
    def initialize(true_color:, ansi256:, ansi:)
      @true_color = true_color
      @ansi256 = ANSIColor.resolve(ansi256)
      @ansi = ANSIColor.resolve(ansi)
    end

    # @rbs return: complete_color_hash
    def to_h
      { true_color: @true_color, ansi256: @ansi256, ansi: @ansi }
    end
  end

  # Complete adaptive color with explicit values for each color profile
  # and separate options for light and dark backgrounds
  #
  # @example
  #   color = Lipgloss::CompleteAdaptiveColor.new(
  #     light: Lipgloss::CompleteColor.new(true_color: "#000", ansi256: :black, ansi: :black),
  #     dark: Lipgloss::CompleteColor.new(true_color: "#FFF", ansi256: :bright_white, ansi: :bright_white)
  #   )
  class CompleteAdaptiveColor
    # @rbs @light: CompleteColor
    # @rbs @dark: CompleteColor

    attr_reader :light #: CompleteColor
    attr_reader :dark #: CompleteColor

    # @rbs light: CompleteColor -- color for light backgrounds
    # @rbs dark: CompleteColor -- color for dark backgrounds
    # @rbs return: void
    def initialize(light:, dark:)
      @light = light
      @dark = dark
    end

    # @rbs return: complete_adaptive_color_hash
    def to_h
      { light: @light.to_h, dark: @dark.to_h }
    end
  end

  module Color # rubocop:disable Metrics/ModuleLength
    # Color profiles (matching Go termenv)
    PROFILE_TRUE_COLOR = :true_color
    PROFILE_ANSI256 = :ansi256
    PROFILE_ANSI = :ansi
    PROFILE_ASCII = :ascii

    # Detect terminal color profile from environment (cached)
    def self.profile
      @profile ||= detect_profile
    end

    # Allow overriding the detected profile
    def self.profile=(value)
      @profile = value
    end

    def self.reset_profile!
      @profile = nil
    end

    def self.detect_profile # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # No color when output is not a TTY (piped)
      return PROFILE_ASCII unless $stdout.tty?

      # NO_COLOR convention (https://no-color.org)
      return PROFILE_ASCII if ENV.key?("NO_COLOR")

      # GOOGLE_CLOUD_SHELL
      return PROFILE_TRUE_COLOR if ENV["GOOGLE_CLOUD_SHELL"] == "true"

      colorterm = ENV.fetch("COLORTERM", "")
      term = ENV.fetch("TERM", "")
      term_program = ENV.fetch("TERM_PROGRAM", "")

      # COLORTERM=truecolor or 24bit
      return PROFILE_TRUE_COLOR if colorterm =~ /truecolor|24bit/i

      # Known truecolor terminals
      return PROFILE_TRUE_COLOR if ["iTerm.app", "WezTerm", "Hyper"].include?(term_program)
      return PROFILE_TRUE_COLOR if term.match?(/\A(alacritty|wezterm|xterm-kitty|contour|tmux)/)

      # COLORTERM=yes or true
      return PROFILE_ANSI256 if colorterm =~ /\A(yes|true)\z/i

      # TERM-based detection
      return PROFILE_ANSI256 if term.include?("256color")
      return PROFILE_ANSI if term.include?("color") || term.include?("ansi")
      return PROFILE_ASCII if term == "dumb"

      # Default: assume truecolor for modern terminals
      PROFILE_TRUE_COLOR
    end # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Convert a color value to foreground ANSI escape code
    # Accepts: hex string (#RGB or #RRGGBB), ANSI number string, AdaptiveColor, CompleteColor, CompleteAdaptiveColor
    def self.to_ansi_fg(color_value)
      code = resolve_color_code(color_value, :fg)
      code ? "\e[#{code}m" : ""
    end

    # Convert a color value to background ANSI escape code
    def self.to_ansi_bg(color_value)
      code = resolve_color_code(color_value, :bg)
      code ? "\e[#{code}m" : ""
    end

    def self.resolve_color_code(color_value, type)
      return nil if profile == PROFILE_ASCII

      case color_value
      when CompleteAdaptiveColor
        cc = has_dark_background? ? color_value.dark : color_value.light
        resolve_complete_color(cc, type)
      when AdaptiveColor
        chosen = has_dark_background? ? color_value.dark : color_value.light
        resolve_string_color(chosen, type)
      when CompleteColor
        resolve_complete_color(color_value, type)
      when String
        resolve_string_color(color_value, type)
      end
    end

    def self.resolve_complete_color(cc, type)
      p = profile
      case p
      when :true_color
        resolve_string_color(cc.true_color, type)
      when :ansi256
        resolve_ansi256(cc.ansi256.to_i, type)
      else
        resolve_ansi_basic(cc.ansi.to_i, type)
      end
    end

    def self.resolve_string_color(str, type)
      return nil if str.nil? || str.empty?

      if str.start_with?("#")
        resolve_hex_color(str, type)
      else
        # Treat as ANSI 256 number
        resolve_ansi256(str.to_i, type)
      end
    end

    def self.resolve_hex_color(hex, type)
      hex = hex.delete_prefix("#")
      # Expand #RGB to #RRGGBB
      hex = hex.chars.map { |c| c * 2 }.join if hex.length == 3
      r = hex[0..1].to_i(16)
      g = hex[2..3].to_i(16)
      b = hex[4..5].to_i(16)
      if type == :fg
        "38;2;#{r};#{g};#{b}"
      else
        "48;2;#{r};#{g};#{b}"
      end
    end

    def self.resolve_ansi256(n, type)
      if type == :fg
        "38;5;#{n}"
      else
        "48;5;#{n}"
      end
    end

    def self.resolve_ansi_basic(n, type)
      if type == :fg
        n < 8 ? (30 + n).to_s : (90 + n - 8).to_s
      else
        n < 8 ? (40 + n).to_s : (100 + n - 8).to_s
      end
    end

    def self.has_dark_background? # rubocop:disable Naming/PredicatePrefix
      bg = ENV.fetch("COLORFGBG", nil)
      return true if bg.nil?

      parts = bg.split(";")
      return true if parts.length < 2

      parts.last.to_i < 8
    end # rubocop:enable Naming/PredicatePrefix
  end # rubocop:enable Metrics/ModuleLength

  module ColorBlend # rubocop:disable Metrics/ModuleLength
    LUV = :luv
    RGB = :rgb
    HCL = :hcl

    class << self
      def blend(c1, c2, t, mode: nil)
        mode ||= :luv
        r1, g1, b1 = parse_hex(c1)
        r2, g2, b2 = parse_hex(c2)

        case mode
        when :rgb
          blend_rgb_values(r1, g1, b1, r2, g2, b2, t)
        when :hcl
          blend_hcl_values(r1, g1, b1, r2, g2, b2, t)
        else # :luv
          blend_luv_values(r1, g1, b1, r2, g2, b2, t)
        end
      end

      def blends(c1, c2, steps, mode: nil)
        mode ||= :luv
        (0...steps).map do |i|
          t = steps <= 1 ? 0.5 : i.to_f / (steps - 1)
          blend(c1, c2, t, mode: mode)
        end
      end

      def grid(x0y0, x1y0, x0y1, x1y1, x_steps, y_steps, mode: nil)
        mode ||= :luv
        (0...y_steps).map do |y|
          ty = y_steps <= 1 ? 0.5 : y.to_f / (y_steps - 1)
          left = blend(x0y0, x0y1, ty, mode: mode)
          right = blend(x1y0, x1y1, ty, mode: mode)
          (0...x_steps).map do |x|
            tx = x_steps <= 1 ? 0.5 : x.to_f / (x_steps - 1)
            blend(left, right, tx, mode: mode)
          end
        end
      end

      private

      def parse_hex(hex)
        hex = hex.delete_prefix("#")
        hex = hex.chars.map { |c| c * 2 }.join if hex.length == 3
        [hex[0..1].to_i(16) / 255.0, hex[2..3].to_i(16) / 255.0, hex[4..5].to_i(16) / 255.0]
      end

      def to_hex(r, g, b)
        r = r.clamp(0.0, 1.0)
        g = g.clamp(0.0, 1.0)
        b = b.clamp(0.0, 1.0)
        format("#%<r>02x%<g>02x%<b>02x", r: (r * 255).round, g: (g * 255).round, b: (b * 255).round)
      end

      def blend_rgb_values(r1, g1, b1, r2, g2, b2, t)
        to_hex(
          r1 + ((r2 - r1) * t),
          g1 + ((g2 - g1) * t),
          b1 + ((b2 - b1) * t)
        )
      end

      # CIE-L*uv blending (simplified but good enough)
      def blend_luv_values(r1, g1, b1, r2, g2, b2, t) # rubocop:disable Metrics/AbcSize
        # Convert to linear RGB, then XYZ, then L*uv, blend, convert back
        l1, u1, v1 = rgb_to_luv(r1, g1, b1)
        l2, u2, v2 = rgb_to_luv(r2, g2, b2)
        l = l1 + ((l2 - l1) * t)
        u = u1 + ((u2 - u1) * t)
        v = v1 + ((v2 - v1) * t)
        r, g, b = luv_to_rgb(l, u, v)
        to_hex(r, g, b)
      end # rubocop:enable Metrics/AbcSize

      def blend_hcl_values(r1, g1, b1, r2, g2, b2, t) # rubocop:disable Metrics/AbcSize
        h1, c1_val, l1 = rgb_to_hcl(r1, g1, b1)
        h2, c2_val, l2 = rgb_to_hcl(r2, g2, b2)

        # Shortest path interpolation for hue
        dh = h2 - h1
        if dh > Math::PI
          dh -= 2 * Math::PI
        elsif dh < -Math::PI
          dh += 2 * Math::PI
        end

        h = h1 + (dh * t)
        c = c1_val + ((c2_val - c1_val) * t)
        l = l1 + ((l2 - l1) * t)
        r, g, b = hcl_to_rgb(h, c, l)
        to_hex(r, g, b)
      end # rubocop:enable Metrics/AbcSize

      # Color space conversion helpers
      def linearize(v)
        v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055)**2.4
      end

      def delinearize(v)
        v <= 0.0031308 ? v * 12.92 : (1.055 * (v**(1.0 / 2.4))) - 0.055
      end

      def rgb_to_xyz(r, g, b) # rubocop:disable Metrics/AbcSize
        rl = linearize(r)
        gl = linearize(g)
        bl = linearize(b)
        x = (0.4124564 * rl) + (0.3575761 * gl) + (0.1804375 * bl)
        y = (0.2126729 * rl) + (0.7151522 * gl) + (0.0721750 * bl)
        z = (0.0193339 * rl) + (0.1191920 * gl) + (0.9503041 * bl)
        [x, y, z]
      end # rubocop:enable Metrics/AbcSize

      def xyz_to_rgb(x, y, z) # rubocop:disable Metrics/AbcSize
        r = delinearize((3.2404542 * x) - (1.5371385 * y) - (0.4985314 * z))
        g = delinearize((-0.9692660 * x) + (1.8760108 * y) + (0.0415560 * z))
        b = delinearize((0.0556434 * x) - (0.2040259 * y) + (1.0572252 * z))
        [r, g, b]
      end # rubocop:enable Metrics/AbcSize

      # rubocop:disable Lint/UselessConstantScoping
      D65_X = 0.95047
      D65_Y = 1.0
      D65_Z = 1.08883
      # rubocop:enable Lint/UselessConstantScoping

      def rgb_to_luv(r, g, b) # rubocop:disable Metrics/AbcSize
        x, y, z = rgb_to_xyz(r, g, b)
        l = if y / D65_Y <= (6.0 / 29.0)**3
              ((29.0 / 3.0)**3) * y / D65_Y
            else
              (116.0 * ((y / D65_Y)**(1.0 / 3.0))) - 16.0
            end
        denom = x + (15.0 * y) + (3.0 * z)
        denom_ref = D65_X + (15.0 * D65_Y) + (3.0 * D65_Z)
        return [0.0, 0.0, 0.0] if denom < 1e-10

        u_prime = 4.0 * x / denom
        v_prime = 9.0 * y / denom
        u_prime_ref = 4.0 * D65_X / denom_ref
        v_prime_ref = 9.0 * D65_Y / denom_ref
        u = 13.0 * l * (u_prime - u_prime_ref)
        v = 13.0 * l * (v_prime - v_prime_ref)
        [l, u, v]
      end # rubocop:enable Metrics/AbcSize

      def luv_to_rgb(l, u, v) # rubocop:disable Metrics/AbcSize
        return [0.0, 0.0, 0.0] if l <= 1e-10

        denom_ref = D65_X + (15.0 * D65_Y) + (3.0 * D65_Z)
        u_prime_ref = 4.0 * D65_X / denom_ref
        v_prime_ref = 9.0 * D65_Y / denom_ref
        u_prime = (u / (13.0 * l)) + u_prime_ref
        v_prime = (v / (13.0 * l)) + v_prime_ref
        y = if l <= 8.0
              D65_Y * l * ((3.0 / 29.0)**3)
            else
              D65_Y * (((l + 16.0) / 116.0)**3)
            end
        return [0.0, 0.0, 0.0] if v_prime.abs < 1e-10

        x = y * 9.0 * u_prime / (4.0 * v_prime)
        z = y * (12.0 - (3.0 * u_prime) - (20.0 * v_prime)) / (4.0 * v_prime)
        xyz_to_rgb(x, y, z)
      end # rubocop:enable Metrics/AbcSize

      def rgb_to_hcl(r, g, b)
        l, u, v = rgb_to_luv(r, g, b)
        c = Math.sqrt((u * u) + (v * v))
        h = Math.atan2(v, u)
        [h, c, l]
      end

      def hcl_to_rgb(h, c, l)
        u = c * Math.cos(h)
        v = c * Math.sin(h)
        luv_to_rgb(l, u, v)
      end
    end
  end # rubocop:enable Metrics/ModuleLength
end
