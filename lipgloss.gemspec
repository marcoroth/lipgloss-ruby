# frozen_string_literal: true

require_relative "lib/lipgloss/version"

Gem::Specification.new do |spec|
  spec.name = "lipgloss"
  spec.version = Lipgloss::VERSION
  spec.authors = ["Marco Roth"]
  spec.email = ["marco.roth@intergga.ch"]

  spec.summary = "Ruby wrapper for Charm's lipgloss. CSS-like terminal styling library."
  spec.description = "Style Definitions for Nice Terminal Layouts. Built with TUIs in mind."
  spec.homepage = "https://github.com/marcoroth/lipgloss-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/marcoroth/lipgloss-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/marcoroth/lipgloss-ruby/releases"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lipgloss.gemspec",
    "LICENSE.txt",
    "README.md",
    "sig/**/*.rbs",
    "lib/**/*.rb",
    "ext/**/*.{c,h,rb}",
    "go/**/*.{go,mod,sum}",
    "go/build/**/*"
  ]

  spec.require_paths = ["lib"]
  spec.extensions = ["ext/lipgloss/extconf.rb"]
end
