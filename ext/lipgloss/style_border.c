#include "extension.h"

static int symbol_to_border_type(VALUE symbol) {
  if (symbol == ID2SYM(rb_intern("normal"))) return BORDER_NORMAL;
  if (symbol == ID2SYM(rb_intern("rounded"))) return BORDER_ROUNDED;
  if (symbol == ID2SYM(rb_intern("thick"))) return BORDER_THICK;
  if (symbol == ID2SYM(rb_intern("double"))) return BORDER_DOUBLE;
  if (symbol == ID2SYM(rb_intern("hidden"))) return BORDER_HIDDEN;
  if (symbol == ID2SYM(rb_intern("block"))) return BORDER_BLOCK;
  if (symbol == ID2SYM(rb_intern("outer_half_block"))) return BORDER_OUTER_HALF_BLOCK;
  if (symbol == ID2SYM(rb_intern("inner_half_block"))) return BORDER_INNER_HALF_BLOCK;
  if (symbol == ID2SYM(rb_intern("ascii"))) return BORDER_ASCII;

  return BORDER_NORMAL;
}

static VALUE style_border(int argc, VALUE *argv, VALUE self) {
  GET_STYLE(self, style);

  if (argc == 0) {
    rb_raise(rb_eArgError, "wrong number of arguments (given 0, expected 1+)");
  }

  int border_type = symbol_to_border_type(argv[0]);

  if (argc == 1) {
    unsigned long long new_handle = lipgloss_style_border(style->handle, border_type, NULL, 0);
    return style_wrap(rb_class_of(self), new_handle);
  }

  int sides[4];
  int sides_count = argc - 1;
  if (sides_count > 4) sides_count = 4;

  for (int index = 0; index < sides_count; index++) {
    sides[index] = RTEST(argv[index + 1]) ? 1 : 0;
  }

  unsigned long long new_handle = lipgloss_style_border(style->handle, border_type, sides, sides_count);

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_style(VALUE self, VALUE border_sym) {
  GET_STYLE(self, style);
  int border_type = symbol_to_border_type(border_sym);
  unsigned long long new_handle = lipgloss_style_border_style(style->handle, border_type);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_foreground(VALUE self, VALUE color) {
  GET_STYLE(self, style);

  if (is_adaptive_color(color)) {
    VALUE light = rb_funcall(color, rb_intern("light"), 0);
    VALUE dark = rb_funcall(color, rb_intern("dark"), 0);

    unsigned long long new_handle = lipgloss_style_border_foreground_adaptive(
      style->handle,
      StringValueCStr(light),
      StringValueCStr(dark)
    );

    return style_wrap(rb_class_of(self), new_handle);
  }

  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_foreground(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_background(VALUE self, VALUE color) {
  GET_STYLE(self, style);

  if (is_adaptive_color(color)) {
    VALUE light = rb_funcall(color, rb_intern("light"), 0);
    VALUE dark = rb_funcall(color, rb_intern("dark"), 0);

    unsigned long long new_handle = lipgloss_style_border_background_adaptive(
      style->handle,
      StringValueCStr(light),
      StringValueCStr(dark)
    );

    return style_wrap(rb_class_of(self), new_handle);
  }

  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_background(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_top(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_border_top(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_right(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_border_right(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_bottom(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_border_bottom(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_left(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_border_left(style->handle, RTEST(value) ? 1 : 0);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_top_foreground(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_top_foreground(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_right_foreground(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_right_foreground(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_bottom_foreground(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_bottom_foreground(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_left_foreground(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_left_foreground(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_top_background(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_top_background(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_right_background(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_right_background(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_bottom_background(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_bottom_background(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_left_background(VALUE self, VALUE color) {
  GET_STYLE(self, style);
  Check_Type(color, T_STRING);
  unsigned long long new_handle = lipgloss_style_border_left_background(style->handle, StringValueCStr(color));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_border_custom(int argc, VALUE *argv, VALUE self) {
  GET_STYLE(self, style);

  VALUE opts;
  rb_scan_args(argc, argv, "0:", &opts);

  if (NIL_P(opts)) {
    rb_raise(rb_eArgError, "keyword arguments required");
  }

  VALUE top = rb_hash_aref(opts, ID2SYM(rb_intern("top")));
  VALUE bottom = rb_hash_aref(opts, ID2SYM(rb_intern("bottom")));
  VALUE left = rb_hash_aref(opts, ID2SYM(rb_intern("left")));
  VALUE right = rb_hash_aref(opts, ID2SYM(rb_intern("right")));
  VALUE top_left = rb_hash_aref(opts, ID2SYM(rb_intern("top_left")));
  VALUE top_right = rb_hash_aref(opts, ID2SYM(rb_intern("top_right")));
  VALUE bottom_left = rb_hash_aref(opts, ID2SYM(rb_intern("bottom_left")));
  VALUE bottom_right = rb_hash_aref(opts, ID2SYM(rb_intern("bottom_right")));
  VALUE middle_left = rb_hash_aref(opts, ID2SYM(rb_intern("middle_left")));
  VALUE middle_right = rb_hash_aref(opts, ID2SYM(rb_intern("middle_right")));
  VALUE middle = rb_hash_aref(opts, ID2SYM(rb_intern("middle")));
  VALUE middle_top = rb_hash_aref(opts, ID2SYM(rb_intern("middle_top")));
  VALUE middle_bottom = rb_hash_aref(opts, ID2SYM(rb_intern("middle_bottom")));

  unsigned long long new_handle = lipgloss_style_border_custom(
    style->handle,
    NIL_P(top) ? "" : StringValueCStr(top),
    NIL_P(bottom) ? "" : StringValueCStr(bottom),
    NIL_P(left) ? "" : StringValueCStr(left),
    NIL_P(right) ? "" : StringValueCStr(right),
    NIL_P(top_left) ? "" : StringValueCStr(top_left),
    NIL_P(top_right) ? "" : StringValueCStr(top_right),
    NIL_P(bottom_left) ? "" : StringValueCStr(bottom_left),
    NIL_P(bottom_right) ? "" : StringValueCStr(bottom_right),
    NIL_P(middle_left) ? "" : StringValueCStr(middle_left),
    NIL_P(middle_right) ? "" : StringValueCStr(middle_right),
    NIL_P(middle) ? "" : StringValueCStr(middle),
    NIL_P(middle_top) ? "" : StringValueCStr(middle_top),
    NIL_P(middle_bottom) ? "" : StringValueCStr(middle_bottom)
  );

  return style_wrap(rb_class_of(self), new_handle);
}

void register_style_border_methods(void) {
  rb_define_method(cStyle, "border", style_border, -1);
  rb_define_method(cStyle, "border_style", style_border_style, 1);
  rb_define_method(cStyle, "border_foreground", style_border_foreground, 1);
  rb_define_method(cStyle, "border_background", style_border_background, 1);
  rb_define_method(cStyle, "border_top", style_border_top, 1);
  rb_define_method(cStyle, "border_right", style_border_right, 1);
  rb_define_method(cStyle, "border_bottom", style_border_bottom, 1);
  rb_define_method(cStyle, "border_left", style_border_left, 1);

  rb_define_method(cStyle, "border_top_foreground", style_border_top_foreground, 1);
  rb_define_method(cStyle, "border_right_foreground", style_border_right_foreground, 1);
  rb_define_method(cStyle, "border_bottom_foreground", style_border_bottom_foreground, 1);
  rb_define_method(cStyle, "border_left_foreground", style_border_left_foreground, 1);
  rb_define_method(cStyle, "border_top_background", style_border_top_background, 1);
  rb_define_method(cStyle, "border_right_background", style_border_right_background, 1);
  rb_define_method(cStyle, "border_bottom_background", style_border_bottom_background, 1);
  rb_define_method(cStyle, "border_left_background", style_border_left_background, 1);

  rb_define_method(cStyle, "border_custom", style_border_custom, -1);
}
