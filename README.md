<div align="center">
  <h1>Lipgloss for Ruby</h1>
  <h4>Style Definitions for Nice Terminal Layouts</h4>

  <p>
    <a href="https://rubygems.org/gems/lipgloss"><img alt="Gem Version" src="https://img.shields.io/gem/v/lipgloss"></a>
    <a href="https://github.com/marcoroth/lipgloss-ruby/blob/main/LICENSE.txt"><img alt="License" src="https://img.shields.io/github/license/marcoroth/lipgloss-ruby"></a>
  </p>

  <p>Ruby bindings for <a href="https://github.com/charmbracelet/lipgloss">charmbracelet/lipgloss</a>.<br/>Style definitions for nice terminal layouts. Built with TUIs in mind.</p>
</div>

## Installation

**Add to your Gemfile:**

```ruby
gem "lipgloss"
```

**Or install directly:**

```bash
gem install lipgloss
```

## Usage

### Basic Styling

**Create and render styled text:**

```ruby
require "lipgloss"

style = Lipgloss::Style.new
  .bold(true)
  .foreground("#FAFAFA")
  .background("#7D56F4")
  .padding(1, 2)

puts style.render("Hello, Lipgloss!")
```

**Reusable styles:**

```ruby
heading = Lipgloss::Style.new
  .bold(true)
  .foreground("#FF6B6B")
  .margin_bottom(1)

body = Lipgloss::Style.new
  .width(40)
  .align(:center)

puts heading.render("Welcome")
puts body.render("Styled terminal output")
```

### Borders

**Add borders to your content:**

```ruby
box = Lipgloss::Style.new
  .border(:rounded)
  .border_foreground("#874BFD")
  .padding(1, 2)

puts box.render("Boxed content")
```

**Available border styles:**

| Style      | Description                       |
|------------|-----------------------------------|
| `:normal`  | Standard box drawing characters   |
| `:rounded` | Rounded corners                   |
| `:thick`   | Thick lines                       |
| `:double`  | Double lines                      |
| `:hidden`  | Hidden (spacing only)             |
| `:block`   | Block characters                  |
| `:ascii`   | ASCII characters (`+`, `-`, `\|`) |

**Custom borders:**

```ruby
style = Lipgloss::Style.new
  .border_custom(
    top: "~", bottom: "~",
    left: "|", right: "|",
    top_left: "+", top_right: "+",
    bottom_left: "+", bottom_right: "+"
  )

puts style.render("Custom border!")
```

**Per-side border colors:**

```ruby
style = Lipgloss::Style.new
  .border(:rounded)
  .border_top_foreground("#FF0000")
  .border_right_foreground("#00FF00")
  .border_bottom_foreground("#0000FF")
  .border_left_foreground("#FFFF00")

puts style.render("Rainbow border!")
```

### Layout

**Join content horizontally:**

```ruby
left = box.render("Left")
right = box.render("Right")

puts Lipgloss.join_horizontal(:top, left, right)
```

**Join content vertically:**

```ruby
puts Lipgloss.join_vertical(:center, left, right)
```

**Place content in whitespace:**

```ruby
puts Lipgloss.place(40, 10, :center, :center, "Centered")
```

**Position symbols:** `:top`, `:bottom`, `:left`, `:right`, `:center` (or numeric 0.0-1.0)

### Colors

**Simple hex colors:**

```ruby
style = Lipgloss::Style.new
  .foreground("#FF0000")
  .background("#0000FF")
```

**Adaptive colors (auto-detect light/dark terminal):**

```ruby
style = Lipgloss::Style.new
  .foreground(Lipgloss::AdaptiveColor.new(light: "#000", dark: "#FFF"))
```

**Complete colors with fallbacks:**

```ruby
color = Lipgloss::CompleteColor.new(
  true_color: "#FF6B6B",  # 24-bit color
  ansi256: 196,           # 256-color fallback (integer)
  ansi: :bright_red       # 16-color fallback (symbol)
)

style = Lipgloss::Style.new.foreground(color)
```

**ANSI color symbols:** `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, `:white`, and bright variants (`:bright_red`, etc.)

**Complete adaptive colors:**

```ruby
light = Lipgloss::CompleteColor.new(true_color: "#000", ansi256: :black, ansi: :black)
dark = Lipgloss::CompleteColor.new(true_color: "#FFF", ansi256: :bright_white, ansi: :bright_white)
color = Lipgloss::CompleteAdaptiveColor.new(light: light, dark: dark)

style = Lipgloss::Style.new.foreground(color)
```

### Style Inheritance

**Inherit styles from a parent:**

```ruby
base = Lipgloss::Style.new
  .foreground("#FF0000")
  .bold(true)

child = Lipgloss::Style.new
  .padding(1)
  .inherit(base)  # Inherits foreground and bold

puts child.render("Inherited style!")
```

**Unset specific properties:**

```ruby
style = Lipgloss::Style.new
  .bold(true)
  .foreground("#FF0000")
  .unset_bold        # Remove bold
  .unset_foreground  # Remove foreground color
```

### SetString

**Set default text for a style:**

```ruby
style = Lipgloss::Style.new
  .bold(true)
  .foreground("#7D56F4")
  .set_string("Hello!")

puts style.to_s  # Renders "Hello!" with the style
```

### Tables

**Create styled tables:**

```ruby
table = Lipgloss::Table.new
  .headers(["Language", "Greeting"])
  .rows([
    ["English", "Hello"],
    ["Spanish", "Hola"],
    ["Japanese", "こんにちは"]
  ])
  .border(:rounded)

puts table.render
```

**Style cells with StyleFunc:**

```ruby
header_style = Lipgloss::Style.new.bold(true).background("#5A56E0")
even_style = Lipgloss::Style.new.background("#3C3C3C")
odd_style = Lipgloss::Style.new.background("#4A4A4A")

table = Lipgloss::Table.new
  .headers(["Name", "Role"])
  .rows([["Alice", "Engineer"], ["Bob", "Designer"]])
  .border(:rounded)
  .style_func(rows: 2, columns: 2) do |row, column|
    if row == Lipgloss::Table::HEADER_ROW
      header_style
    elsif row.even?
      even_style
    else
      odd_style
    end
  end

puts table.render
```

### Lists

**Create styled lists:**

```ruby
list = Lipgloss::List.new
  .items(["First item", "Second item", "Third item"])
  .enumerator(:bullet)

puts list.render
```

**Available enumerators:**

| Enumerator  | Output             |
|-------------|--------------------|
| `:bullet`   | `•`                |
| `:dash`     | `-`                |
| `:asterisk` | `*`                |
| `:arabic`   | `1.`, `2.`, `3.`   |
| `:alphabet` | `A.`, `B.`, `C.`   |
| `:roman`    | `I.`, `II.`, `III.` |

**Styled list items:**

```ruby
list = Lipgloss::List.new
  .items(["Red", "Green", "Blue"])
  .enumerator(:bullet)
  .enumerator_style(Lipgloss::Style.new.foreground("#FF0000"))
  .item_style(Lipgloss::Style.new.bold(true))

puts list.render
```

### Trees

**Create tree structures:**

```ruby
tree = Lipgloss::Tree.new
  .root("Project")
  .child("src")
  .child("lib")
  .child("test")

puts tree.render
```

**Nested trees:**

```ruby
src = Lipgloss::Tree.new.root("src").child("main.rb").child("helper.rb")
test = Lipgloss::Tree.new.root("test").child("test_main.rb")

tree = Lipgloss::Tree.new
  .root("Project")
  .child(src)
  .child(test)

puts tree.render
```

## Style Methods

### Text Formatting

| Method                | Description                   |
|-----------------------|-------------------------------|
| `bold(bool)`          | Bold text                     |
| `italic(bool)`        | Italic text                   |
| `underline(bool)`     | Underlined text               |
| `strikethrough(bool)` | Strikethrough text            |
| `reverse(bool)`       | Reverse foreground/background |
| `blink(bool)`         | Blinking text                 |
| `faint(bool)`         | Dimmed text                   |

### Colors

| Method                     | Description             |
|----------------------------|-------------------------|
| `foreground(color)`        | Text color              |
| `background(color)`        | Background color        |
| `margin_background(color)` | Margin background color |

### Dimensions

| Method           | Description    |
|------------------|----------------|
| `width(int)`     | Set width      |
| `height(int)`    | Set height     |
| `max_width(int)` | Maximum width  |
| `max_height(int)`| Maximum height |

### Spacing

| Method                                         | Description           |
|------------------------------------------------|-----------------------|
| `padding(top, right, bottom, left)`            | Padding (CSS shorthand) |
| `padding_top(int)`, `padding_right(int)`, etc. | Individual padding    |
| `margin(top, right, bottom, left)`             | Margin (CSS shorthand) |
| `margin_top(int)`, `margin_right(int)`, etc.   | Individual margin     |

### Borders

| Method                                         | Description                 |
|------------------------------------------------|-----------------------------|
| `border(type, *sides)`                         | Set border type and sides   |
| `border_style(type)`                           | Set border type only        |
| `border_foreground(color)`                     | Border color (all sides)    |
| `border_background(color)`                     | Border background (all sides) |
| `border_top_foreground(color)`, etc.           | Per-side border colors      |
| `border_top_background(color)`, etc.           | Per-side border backgrounds |
| `border_top(bool)`, `border_right(bool)`, etc. | Enable/disable sides        |
| `border_custom(**opts)`                        | Custom border characters    |

### Alignment

| Method                        | Description          |
|-------------------------------|----------------------|
| `align(horizontal, vertical)` | Set alignment        |
| `align_horizontal(position)`  | Horizontal alignment |
| `align_vertical(position)`    | Vertical alignment   |

**Position symbols:** `:top`, `:bottom`, `:left`, `:right`, `:center` (or numeric 0.0-1.0)

### Other

| Method             | Description                               |
|--------------------|-------------------------------------------|
| `inline(bool)`     | Render inline (no margins/padding/borders) |
| `tab_width(int)`   | Tab character width (-1 to disable)       |
| `set_string(text)` | Set default text                          |
| `inherit(style)`   | Inherit from another style                |
| `to_s`             | Render with default text                  |

### Unset Methods

| Method                                 | Description          |
|----------------------------------------|----------------------|
| `unset_bold`, `unset_italic`, etc.     | Clear text formatting |
| `unset_foreground`, `unset_background` | Clear colors         |
| `unset_width`, `unset_height`          | Clear dimensions     |
| `unset_padding_top`, etc.              | Clear padding        |
| `unset_margin_top`, etc.               | Clear margin         |
| `unset_border_style`                   | Clear border         |
| `unset_inline`                         | Clear inline         |

## Module Methods

| Method                                                    | Description               |
|-----------------------------------------------------------|---------------------------|
| `Lipgloss.join_horizontal(position, *strings)`            | Join strings horizontally |
| `Lipgloss.join_vertical(position, *strings)`              | Join strings vertically   |
| `Lipgloss.width(string)`                                  | Get rendered width        |
| `Lipgloss.height(string)`                                 | Get rendered height       |
| `Lipgloss.size(string)`                                   | Get `[width, height]`     |
| `Lipgloss.place(width, height, h_pos, v_pos, string)`     | Place in whitespace       |
| `Lipgloss.place_horizontal(width, position, string)`      | Place horizontally        |
| `Lipgloss.place_vertical(height, position, string)`       | Place vertically          |
| `Lipgloss.has_dark_background?`                           | Check terminal background |

### Color Blending

| Method                                                         | Description                    |
|----------------------------------------------------------------|--------------------------------|
| `Lipgloss::ColorBlend.blend(c1, c2, t, mode:)`                 | Blend two colors (0.0-1.0)     |
| `Lipgloss::ColorBlend.blends(c1, c2, steps, mode:)`            | Generate color gradient array  |
| `Lipgloss::ColorBlend.grid(c1, c2, c3, c4, x, y, mode:)`       | Generate 2D color grid         |

**Blend modes:** `:luv` (default, perceptually uniform), `:rgb`, `:hcl`

#### Generate a 5-color gradient

```ruby
colors = Lipgloss::ColorBlend.blends("#FF0000", "#0000FF", 5)
# => ["#ff0000", "#c1007f", "#7a00c1", "#0000ff", ...]
```

#### Blend two colors at 50%

```ruby
mid = Lipgloss::ColorBlend.blend("#FF0000", "#00FF00", 0.5)
# => "#b5b500"
```

## Development

**Requirements:**
- Go 1.23+
- Ruby 3.2+

**Install dependencies:**

```bash
bundle install
```

**Build the Go library and compile the extension:**

```bash
bundle exec rake compile
```

**Run tests:**

```bash
bundle exec rake test
```

**Run demos:**

```bash
./demo/basic
./demo/colors
./demo/layout
./demo/table
./demo/list
./demo/tree
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcoroth/lipgloss-ruby.

## License

The gem is available as open source under the terms of the MIT License.

## Acknowledgments

This gem wraps [charmbracelet/lipgloss](https://github.com/charmbracelet/lipgloss), part of the excellent [Charm](https://charm.sh) ecosystem.
