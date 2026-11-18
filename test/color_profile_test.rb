# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class ColorProfileTest < Minitest::Spec
    before do
      @profile = Lipgloss.color_profile
    end

    after do
      Lipgloss.color_profile = @profile
    end

    it "renders without colors for the ascii profile" do
      Lipgloss.color_profile = :ascii

      assert_equal :ascii, Lipgloss.color_profile
      assert_equal "hello", Lipgloss::Style.new.foreground("212").bold(true).render("hello")
    end

    it "renders colors for the true_color profile" do
      Lipgloss.color_profile = :true_color

      assert_equal :true_color, Lipgloss.color_profile
      assert_includes Lipgloss::Style.new.foreground("#ff0000").render("hello"), "\e[38;2;255;0;0m"
    end

    it "renders 256 colors for the ansi256 profile" do
      Lipgloss.color_profile = :ansi256

      assert_includes Lipgloss::Style.new.foreground("212").render("hello"), "\e[38;5;212m"
    end

    it "rejects unknown profiles" do
      assert_raises(ArgumentError) { Lipgloss.color_profile = :rainbow }
    end
  end
end
