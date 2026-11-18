# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class StyleToHTest < Minitest::Spec
    it "is empty for a new style" do
      assert_equal({}, Lipgloss::Style.new.to_h)
    end

    it "includes attributes and colors that are set" do
      hash = Lipgloss::Style.new.bold(true).italic(true).foreground("#7aa2f7").background("235").to_h

      assert_equal true, hash[:bold]
      assert_equal true, hash[:italic]
      assert_equal "#7aa2f7", hash[:foreground]
      assert_equal "235", hash[:background]
      refute hash.key?(:underline)
    end

    it "includes sizes, alignment, padding, and margin" do
      hash = Lipgloss::Style.new.width(20).height(3).align(:center, :bottom).padding(1, 2).margin(0, 1).to_h

      assert_equal 20, hash[:width]
      assert_equal 3, hash[:height]
      assert_in_delta 0.5, hash[:align_horizontal]
      assert_in_delta 1.0, hash[:align_vertical]
      assert_equal [1, 2, 1, 2], hash[:padding]
      assert_equal [0, 1, 0, 1], hash[:margin]
    end

    it "includes the border, its sides, and its colors" do
      hash = Lipgloss::Style.new.border(:rounded).border_foreground("63").to_h

      assert_equal "╭", hash[:border][:top_left]
      assert_equal "─", hash[:border][:top]
      assert_equal [true, true, true, true], hash[:border_sides]
      assert_equal ["63", "63", "63", "63"], hash[:border_foreground]
      refute hash.key?(:border_background)
    end

    it "includes adaptive colors as a hash" do
      hash = Lipgloss::Style.new.foreground(Lipgloss::AdaptiveColor.new(light: "#000000", dark: "#ffffff")).to_h

      assert_equal({ light: "#000000", dark: "#ffffff" }, hash[:foreground])
    end
  end
end
