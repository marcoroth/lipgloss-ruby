#include "extension.h"

static VALUE style_padding(int argc, VALUE *argv, VALUE self) {
  GET_STYLE(self, style);

  if (argc == 0 || argc > 4) {
    rb_raise(rb_eArgError, "wrong number of arguments (given %d, expected 1..4)", argc);
  }

  int values[4];
  for (int index = 0; index < argc; index++) {
    values[index] = NUM2INT(argv[index]);
  }

  unsigned long long new_handle = lipgloss_style_padding(style->handle, values, argc);

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_padding_top(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_padding_top(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_padding_right(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_padding_right(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_padding_bottom(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_padding_bottom(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_padding_left(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_padding_left(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_margin(int argc, VALUE *argv, VALUE self) {
  GET_STYLE(self, style);

  if (argc == 0 || argc > 4) {
    rb_raise(rb_eArgError, "wrong number of arguments (given %d, expected 1..4)", argc);
  }

  int values[4];
  for (int index = 0; index < argc; index++) {
    values[index] = NUM2INT(argv[index]);
  }

  unsigned long long new_handle = lipgloss_style_margin(style->handle, values, argc);

  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_margin_top(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_margin_top(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_margin_right(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_margin_right(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_margin_bottom(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_margin_bottom(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_margin_left(VALUE self, VALUE value) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_margin_left(style->handle, NUM2INT(value));
  return style_wrap(rb_class_of(self), new_handle);
}

void register_style_spacing_methods(void) {
  rb_define_method(cStyle, "padding", style_padding, -1);
  rb_define_method(cStyle, "padding_top", style_padding_top, 1);
  rb_define_method(cStyle, "padding_right", style_padding_right, 1);
  rb_define_method(cStyle, "padding_bottom", style_padding_bottom, 1);
  rb_define_method(cStyle, "padding_left", style_padding_left, 1);

  rb_define_method(cStyle, "margin", style_margin, -1);
  rb_define_method(cStyle, "margin_top", style_margin_top, 1);
  rb_define_method(cStyle, "margin_right", style_margin_right, 1);
  rb_define_method(cStyle, "margin_bottom", style_margin_bottom, 1);
  rb_define_method(cStyle, "margin_left", style_margin_left, 1);
}
