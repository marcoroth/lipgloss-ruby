# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class ListTest < Minitest::Spec
    it "renders basic list" do
      list = Lipgloss::List.new("Apple", "Banana", "Cherry")

      result = strip_ansi(list.render)
      expected = "• Apple\n• Banana\n• Cherry"

      assert_equal expected, result
    end

    it "renders empty list with items" do
      list = Lipgloss::List.new
                           .items(["One", "Two", "Three"])

      result = strip_ansi(list.render)
      expected = "• One\n• Two\n• Three"

      assert_equal expected, result
    end

    it "renders with item method" do
      list = Lipgloss::List.new
                           .item("First")
                           .item("Second")

      result = strip_ansi(list.render)
      expected = "• First\n• Second"

      assert_equal expected, result
    end

    it "renders with bullet enumerator" do
      list = Lipgloss::List.new("A", "B")
                           .enumerator(:bullet)

      result = strip_ansi(list.render)
      expected = "• A\n• B"

      assert_equal expected, result
    end

    it "renders with arabic enumerator" do
      list = Lipgloss::List.new("A", "B", "C")
                           .enumerator(:arabic)

      result = strip_ansi(list.render)
      expected = "1. A\n2. B\n3. C"

      assert_equal expected, result
    end

    it "renders with alphabet enumerator" do
      list = Lipgloss::List.new("X", "Y", "Z")
                           .enumerator(:alphabet)

      result = strip_ansi(list.render)
      expected = "A. X\nB. Y\nC. Z"

      assert_equal expected, result
    end

    it "renders with roman enumerator" do
      list = Lipgloss::List.new("One", "Two", "Three", "Four")
                           .enumerator(:roman)

      result = strip_ansi(list.render)
      expected = "  I. One\n II. Two\nIII. Three\n IV. Four"

      assert_equal expected, result
    end

    it "renders with dash enumerator" do
      list = Lipgloss::List.new("Item")
                           .enumerator(:dash)

      result = strip_ansi(list.render)
      expected = "- Item"

      assert_equal expected, result
    end

    it "renders with asterisk enumerator" do
      list = Lipgloss::List.new("Item")
                           .enumerator(:asterisk)

      result = strip_ansi(list.render)
      expected = "* Item"

      assert_equal expected, result
    end

    it "renders nested list" do
      sublist = Lipgloss::List.new("Sub A", "Sub B")
      list = Lipgloss::List.new
                           .item("Main")
                           .item(sublist)

      result = strip_ansi(list.render)
      expected = "• Main\n  • Sub A\n  • Sub B"

      assert_equal expected, result
    end

    it "renders with enumerator style" do
      style = Lipgloss::Style.new.foreground("#FF0000")
      list = Lipgloss::List.new("A", "B")
                           .enumerator(:bullet)
                           .enumerator_style(style)

      result = strip_ansi(list.render)
      expected = "•A\n•B"

      assert_equal expected, result
    end

    it "renders with item style" do
      style = Lipgloss::Style.new.bold(true)
      list = Lipgloss::List.new("Bold Item")
                           .item_style(style)

      result = strip_ansi(list.render)
      expected = "• Bold Item"

      assert_equal expected, result
    end

    it "converts to string with to_s" do
      list = Lipgloss::List.new("Test")
      assert_equal list.render, list.to_s
    end

    it "maintains immutability" do
      list1 = Lipgloss::List.new
      list2 = list1.item("X")

      refute_equal list1.object_id, list2.object_id
    end

    it "chains multiple options" do
      list = Lipgloss::List.new
                           .item("A")
                           .item("B")
                           .item("C")
                           .enumerator(:arabic)

      result = strip_ansi(list.render)
      expected = "1. A\n2. B\n3. C"

      assert_equal expected, result
    end
  end
end
