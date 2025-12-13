#include "extension.h"

static VALUE style_unset_bold(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_bold(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_italic(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_italic(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_underline(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_underline(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_strikethrough(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_strikethrough(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_reverse(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_reverse(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_blink(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_blink(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_faint(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_faint(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_foreground(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_foreground(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_background(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_background(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_width(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_width(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_height(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_height(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_padding_top(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_padding_top(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_padding_right(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_padding_right(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_padding_bottom(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_padding_bottom(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_padding_left(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_padding_left(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_margin_top(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_margin_top(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_margin_right(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_margin_right(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_margin_bottom(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_margin_bottom(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_margin_left(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_margin_left(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_border_style(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_border_style(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

static VALUE style_unset_inline(VALUE self) {
  GET_STYLE(self, style);
  unsigned long long new_handle = lipgloss_style_unset_inline(style->handle);
  return style_wrap(rb_class_of(self), new_handle);
}

void register_style_unset_methods(void) {
  rb_define_method(cStyle, "unset_bold", style_unset_bold, 0);
  rb_define_method(cStyle, "unset_italic", style_unset_italic, 0);
  rb_define_method(cStyle, "unset_underline", style_unset_underline, 0);
  rb_define_method(cStyle, "unset_strikethrough", style_unset_strikethrough, 0);
  rb_define_method(cStyle, "unset_reverse", style_unset_reverse, 0);
  rb_define_method(cStyle, "unset_blink", style_unset_blink, 0);
  rb_define_method(cStyle, "unset_faint", style_unset_faint, 0);
  rb_define_method(cStyle, "unset_foreground", style_unset_foreground, 0);
  rb_define_method(cStyle, "unset_background", style_unset_background, 0);
  rb_define_method(cStyle, "unset_width", style_unset_width, 0);
  rb_define_method(cStyle, "unset_height", style_unset_height, 0);
  rb_define_method(cStyle, "unset_padding_top", style_unset_padding_top, 0);
  rb_define_method(cStyle, "unset_padding_right", style_unset_padding_right, 0);
  rb_define_method(cStyle, "unset_padding_bottom", style_unset_padding_bottom, 0);
  rb_define_method(cStyle, "unset_padding_left", style_unset_padding_left, 0);
  rb_define_method(cStyle, "unset_margin_top", style_unset_margin_top, 0);
  rb_define_method(cStyle, "unset_margin_right", style_unset_margin_right, 0);
  rb_define_method(cStyle, "unset_margin_bottom", style_unset_margin_bottom, 0);
  rb_define_method(cStyle, "unset_margin_left", style_unset_margin_left, 0);
  rb_define_method(cStyle, "unset_border_style", style_unset_border_style, 0);
  rb_define_method(cStyle, "unset_inline", style_unset_inline, 0);
}
