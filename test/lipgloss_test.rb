# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class LipglossTest < Minitest::Spec
    it "has a version number" do
      refute_nil Lipgloss::VERSION
    end

    it "has position constants" do
      assert_equal 0.0, Lipgloss::TOP
      assert_equal 1.0, Lipgloss::BOTTOM
      assert_equal 0.0, Lipgloss::LEFT
      assert_equal 1.0, Lipgloss::RIGHT
      assert_equal 0.5, Lipgloss::CENTER
    end

    it "has border constants" do
      assert_equal :normal, Lipgloss::NORMAL_BORDER
      assert_equal :rounded, Lipgloss::ROUNDED_BORDER
      assert_equal :thick, Lipgloss::THICK_BORDER
      assert_equal :double, Lipgloss::DOUBLE_BORDER
      assert_equal :hidden, Lipgloss::HIDDEN_BORDER
      assert_equal :block, Lipgloss::BLOCK_BORDER
      assert_equal :ascii, Lipgloss::ASCII_BORDER
    end

    it "has no tab conversion constant" do
      assert_equal(-1, Lipgloss::NO_TAB_CONVERSION)
    end
  end
end
