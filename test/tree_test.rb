# frozen_string_literal: true

require_relative "test_helper"

module Lipgloss
  class TreeTest < Minitest::Spec
    it "renders basic tree" do
      tree = Lipgloss::Tree.root("Root")
                           .child("Child 1", "Child 2")

      result = strip_ansi(tree.render)
      expected = "Root\n├── Child 1\n└── Child 2"

      assert_equal expected, result
    end

    it "renders tree with new" do
      tree = Lipgloss::Tree.new("MyRoot")
                           .child("A", "B")

      result = strip_ansi(tree.render)
      expected = "MyRoot\n├── A\n└── B"

      assert_equal expected, result
    end

    it "renders tree structure characters" do
      tree = Lipgloss::Tree.root("Root")
                           .child("A", "B", "C")

      result = strip_ansi(tree.render)
      expected = "Root\n├── A\n├── B\n└── C"

      assert_equal expected, result
    end

    it "renders nested tree" do
      subtree = Lipgloss::Tree.root("Subdir")
                              .child("file1.rb", "file2.rb")

      tree = Lipgloss::Tree.root("Project")
                           .child(subtree)
                           .child("README.md")

      result = strip_ansi(tree.render)
      expected = "Project\n├── Subdir\n│   ├── file1.rb\n│   └── file2.rb\n└── README.md"

      assert_equal expected, result
    end

    it "renders with children method" do
      tree = Lipgloss::Tree.root("Root")
                           .children(["A", "B", "C"])

      result = strip_ansi(tree.render)
      expected = "Root\n├── A\n├── B\n└── C"

      assert_equal expected, result
    end

    it "renders with default enumerator" do
      tree = Lipgloss::Tree.root("Root")
                           .child("A")
                           .enumerator(:default)

      result = strip_ansi(tree.render)
      expected = "Root\n└── A"

      assert_equal expected, result
    end

    it "renders with rounded enumerator" do
      tree = Lipgloss::Tree.root("Root")
                           .child("A")
                           .enumerator(:rounded)

      result = strip_ansi(tree.render)
      expected = "Root\n╰── A"

      assert_equal expected, result
    end

    it "renders with enumerator style" do
      style = Lipgloss::Style.new.foreground("#00FF00")
      tree = Lipgloss::Tree.root("Root")
                           .child("A")
                           .enumerator_style(style)

      result = strip_ansi(tree.render)
      expected = "Root\n└──A"

      assert_equal expected, result
    end

    it "renders with item style" do
      style = Lipgloss::Style.new.italic(true)
      tree = Lipgloss::Tree.root("Root")
                           .child("Item")
                           .item_style(style)

      result = strip_ansi(tree.render)
      expected = "Root\n└── Item"

      assert_equal expected, result
    end

    it "renders with root style" do
      style = Lipgloss::Style.new.bold(true)
      tree = Lipgloss::Tree.root("StyledRoot")
                           .child("A")
                           .root_style(style)

      result = strip_ansi(tree.render)
      expected = "StyledRoot\n└── A"

      assert_equal expected, result
    end

    it "converts to string with to_s" do
      tree = Lipgloss::Tree.root("Test")
                           .child("A")

      assert_equal tree.render, tree.to_s
    end

    it "maintains immutability" do
      tree1 = Lipgloss::Tree.root("Root")
      tree2 = tree1.child("Child")

      refute_equal tree1.object_id, tree2.object_id
    end

    it "renders complex tree structure" do
      src = Lipgloss::Tree.root("src")
                          .child("main.rb", "helper.rb")

      test_dir = Lipgloss::Tree.root("test")
                               .child("test_main.rb")

      tree = Lipgloss::Tree.root("my_project")
                           .child(src, test_dir, "README.md", "Gemfile")

      result = strip_ansi(tree.render)
      expected = "my_project\n├── src\n│   ├── main.rb\n│   └── helper.rb\n├── test\n│   └── test_main.rb\n├── README.md\n└── Gemfile"

      assert_equal expected, result
    end

    it "chains multiple options" do
      tree = Lipgloss::Tree.root("Root")
                           .child("A")
                           .child("B")
                           .child("C")
                           .enumerator(:rounded)

      result = strip_ansi(tree.render)
      expected = "Root\n├── A\n├── B\n╰── C"

      assert_equal expected, result
    end
  end
end
