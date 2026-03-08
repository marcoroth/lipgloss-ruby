# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "lipgloss"
require "maxitest/autorun"

# Force truecolor profile in tests (tests run in non-TTY context)
Lipgloss::Color.profile = :true_color

def strip_ansi(string)
  string.gsub(/\e\[[0-9;]*[A-Za-z]/, "")
end
