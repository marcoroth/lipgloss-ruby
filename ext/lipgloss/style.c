#include "extension.h"

static void style_free(void *pointer) {
  lipgloss_style_t *style = (lipgloss_style_t *) pointer;

  if (style->handle != 0) {
    lipgloss_free_style(style->handle);
  }

  xfree(style);
}

static size_t style_memsize(const void *pointer) {
  return sizeof(lipgloss_style_t);
}

const rb_data_type_t style_type = {
  .wrap_struct_name = "Lipgloss::Style",
  .function = {
    .dmark = NULL,
    .dfree = style_free,
    .dsize = style_memsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE style_alloc(VALUE klass) {
  lipgloss_style_t *style = ALLOC(lipgloss_style_t);
  style->handle = lipgloss_new_style();
  return TypedData_Wrap_Struct(klass, &style_type, style);
}

VALUE style_wrap(VALUE klass, unsigned long long handle) {
  lipgloss_style_t *style = ALLOC(lipgloss_style_t);

  style->handle = handle;

  return TypedData_Wrap_Struct(klass, &style_type, style);
}

static VALUE style_initialize(VALUE self) {
  return self;
}

static VALUE style_render(VALUE self, VALUE string) {
  GET_STYLE(self, style);
  Check_Type(string, T_STRING);

  char *result = lipgloss_style_render(style->handle, StringValueCStr(string));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);

  return rb_result;
}

// Formatting methods

static VALUE style_bold(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_bold(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_italic(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_italic(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_underline(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_underline(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_strikethrough(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_strikethrough(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_reverse(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_reverse(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_blink(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_blink(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_faint(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_faint(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

// Color helper functions

static int is_complete_color(VALUE obj) {
  return rb_respond_to(obj, rb_intern("true_color")) && rb_respond_to(obj, rb_intern("ansi256")) && rb_respond_to(obj, rb_intern("ansi"));
}

// Color methods

static VALUE style_foreground(VALUE self, VALUE color) {
  GET_STYLE(self, style);

  if (is_adaptive_color(color)) {
    VALUE light = rb_funcall(color, rb_intern("light"), 0);
    VALUE dark = rb_funcall(color, rb_intern("dark"), 0);

    if (is_complete_color(light) && is_complete_color(dark)) {
      VALUE light_true = rb_funcall(light, rb_intern("true_color"), 0);
      VALUE light_256 = rb_funcall(light, rb_intern("ansi256"), 0);
      VALUE light_ansi = rb_funcall(light, rb_intern("ansi"), 0);
      VALUE dark_true = rb_funcall(dark, rb_intern("true_color"), 0);
      VALUE dark_256 = rb_funcall(dark, rb_intern("ansi256"), 0);
      VALUE dark_ansi = rb_funcall(dark, rb_intern("ansi"), 0);

      unsigned long long new_handle = lipgloss_style_foreground_complete_adaptive(
        style->handle,
        StringValueCStr(light_true),
        StringValueCStr(light_256),
        StringValueCStr(light_ansi),
        StringValueCStr(dark_true),
        StringValueCStr(dark_256),
        StringValueCStr(dark_ansi)
      );

      return style_wrap(rb_class_of(self), new_handle);
    }

    unsigned long long new_handle = lipgloss_style_foreground_adaptive(
      style->handle,
      StringValueCStr(light),
      StringValueCStr(dark)
    );

    return style_wrap(rb_class_of(self), new_handle);
  }

  if (is_complete_color(color)) {
    VALUE true_color = rb_funcall(color, rb_intern("true_color"), 0);
    VALUE ansi256 = rb_funcall(color, rb_intern("ansi256"), 0);
    VALUE ansi = rb_funcall(color, rb_intern("ansi"), 0);

    unsigned long long new_handle = lipgloss_style_foreground_complete(
      style->handle,
      StringValueCStr(true_color),
      StringValueCStr(ansi256),
      StringValueCStr(ansi)
    );

    return style_wrap(rb_class_of(self), new_handle);
  }

  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_foreground(style->handle, StringValueCStr(color));

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_background(VALUE self, VALUE color) {
  GET_STYLE(self, style);

  if (is_adaptive_color(color)) {
    VALUE light = rb_funcall(color, rb_intern("light"), 0);
    VALUE dark = rb_funcall(color, rb_intern("dark"), 0);

    if (is_complete_color(light) && is_complete_color(dark)) {
      VALUE light_true = rb_funcall(light, rb_intern("true_color"), 0);
      VALUE light_256 = rb_funcall(light, rb_intern("ansi256"), 0);
      VALUE light_ansi = rb_funcall(light, rb_intern("ansi"), 0);
      VALUE dark_true = rb_funcall(dark, rb_intern("true_color"), 0);
      VALUE dark_256 = rb_funcall(dark, rb_intern("ansi256"), 0);
      VALUE dark_ansi = rb_funcall(dark, rb_intern("ansi"), 0);

      unsigned long long new_handle = lipgloss_style_background_complete_adaptive(
        style->handle,
        StringValueCStr(light_true),
        StringValueCStr(light_256),
        StringValueCStr(light_ansi),
        StringValueCStr(dark_true),
        StringValueCStr(dark_256),
        StringValueCStr(dark_ansi)
      );

      return style_wrap(rb_class_of(self), new_handle);
    }

    unsigned long long new_handle = lipgloss_style_background_adaptive(
      style->handle,
      StringValueCStr(light),
      StringValueCStr(dark)
    );

    return style_wrap(rb_class_of(self), new_handle);
  }

  if (is_complete_color(color)) {
    VALUE true_color = rb_funcall(color, rb_intern("true_color"), 0);
    VALUE ansi256 = rb_funcall(color, rb_intern("ansi256"), 0);
    VALUE ansi = rb_funcall(color, rb_intern("ansi"), 0);

    unsigned long long new_handle = lipgloss_style_background_complete(
      style->handle,
      StringValueCStr(true_color),
      StringValueCStr(ansi256),
      StringValueCStr(ansi)
    );

    return style_wrap(rb_class_of(self), new_handle);
  }

  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_background(style->handle, StringValueCStr(color));

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_margin_background(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);

  unsigned long long new_handle = lipgloss_style_margin_background(style->handle, StringValueCStr(color));

  return style_wrap(rb_class_of(self), new_handle);
}

// Size methods

static VALUE style_width(VALUE self, VALUE width) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_width(style->handle, NUM2INT(width));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_height(VALUE self, VALUE height) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_height(style->handle, NUM2INT(height));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_max_width(VALUE self, VALUE width) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_max_width(style->handle, NUM2INT(width));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_max_height(VALUE self, VALUE height) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_max_height(style->handle, NUM2INT(height));
  return style_wrap(rb_class_of(self), new_handle);
}

// Alignment methods

static VALUE style_align(int argc, VALUE *argv, VALUE self) {
  GET_STYLE(self, style);

  if (argc == 0 || argc > 2) {
    rb_raise(rb_eArgError, "wrong number of arguments (given %d, expected 1..2)", argc);
  }

  double positions[2];
  for (int index = 0; index < argc; index++) {
    positions[index] = NUM2DBL(argv[index]);
  }

  unsigned long long new_handle = lipgloss_style_align(style->handle, positions, argc);

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_align_horizontal(VALUE self, VALUE position) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_align_horizontal(style->handle, NUM2DBL(position));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_align_vertical(VALUE self, VALUE position) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_align_vertical(style->handle, NUM2DBL(position));
  return style_wrap(rb_class_of(self), new_handle);
}

// Other style methods

static VALUE style_inline(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_inline(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_tab_width(VALUE self, VALUE width) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_tab_width(style->handle, NUM2INT(width));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_underline_spaces(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_underline_spaces(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_strikethrough_spaces(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_strikethrough_spaces(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

// SetString, Inherit, to_s

static VALUE style_set_string(VALUE self, VALUE string) {
  GET_STYLE(self, style);
  Check_Type(string, T_STRING);

  unsigned long long new_handle = lipgloss_style_set_string(style->handle, StringValueCStr(string));

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_inherit(VALUE self, VALUE other) {
  GET_STYLE(self, style);
  lipgloss_style_t *other_style;

  TypedData_Get_Struct(other, lipgloss_style_t, &style_type, other_style);
  unsigned long long new_handle = lipgloss_style_inherit(style->handle, other_style->handle);

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_to_s(VALUE self) {
  GET_STYLE(self, style);
  char *result = lipgloss_style_string(style->handle);
  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

void Init_lipgloss_style(void) {
  cStyle = rb_define_class_under(mLipgloss, "Style", rb_cObject);

  rb_define_alloc_func(cStyle, style_alloc);

  rb_define_method(cStyle, "initialize", style_initialize, 0);
  rb_define_method(cStyle, "render", style_render, 1);

  // Formatting
  rb_define_method(cStyle, "bold", style_bold, 1);
  rb_define_method(cStyle, "italic", style_italic, 1);
  rb_define_method(cStyle, "underline", style_underline, 1);
  rb_define_method(cStyle, "strikethrough", style_strikethrough, 1);
  rb_define_method(cStyle, "reverse", style_reverse, 1);
  rb_define_method(cStyle, "blink", style_blink, 1);
  rb_define_method(cStyle, "faint", style_faint, 1);

  // Colors
  rb_define_method(cStyle, "foreground", style_foreground, 1);
  rb_define_method(cStyle, "background", style_background, 1);
  rb_define_method(cStyle, "margin_background", style_margin_background, 1);

  // Size
  rb_define_method(cStyle, "width", style_width, 1);
  rb_define_method(cStyle, "height", style_height, 1);
  rb_define_method(cStyle, "max_width", style_max_width, 1);
  rb_define_method(cStyle, "max_height", style_max_height, 1);

  // Alignment
  rb_define_method(cStyle, "_align", style_align, -1);
  rb_define_method(cStyle, "_align_horizontal", style_align_horizontal, 1);
  rb_define_method(cStyle, "_align_vertical", style_align_vertical, 1);

  // Other
  rb_define_method(cStyle, "inline", style_inline, 1);
  rb_define_method(cStyle, "tab_width", style_tab_width, 1);
  rb_define_method(cStyle, "underline_spaces", style_underline_spaces, 1);
  rb_define_method(cStyle, "strikethrough_spaces", style_strikethrough_spaces, 1);

  rb_define_method(cStyle, "set_string", style_set_string, 1);
  rb_define_method(cStyle, "inherit", style_inherit, 1);
  rb_define_method(cStyle, "to_s", style_to_s, 0);

  // Register methods from sub-files
  register_style_spacing_methods();
  register_style_border_methods();
  register_style_unset_methods();
}
