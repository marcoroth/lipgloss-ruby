#include "extension.h"

VALUE mLipgloss;
VALUE cStyle;
VALUE cTable;
VALUE cList;
VALUE cTree;

static VALUE lipgloss_join_horizontal_rb(VALUE self, VALUE position, VALUE strings) {
  Check_Type(strings, T_ARRAY);

  VALUE json_str = rb_funcall(strings, rb_intern("to_json"), 0);
  char *result = lipgloss_join_horizontal(NUM2DBL(position), StringValueCStr(json_str));
  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

static VALUE lipgloss_join_vertical_rb(VALUE self, VALUE position, VALUE strings) {
  Check_Type(strings, T_ARRAY);

  VALUE json_str = rb_funcall(strings, rb_intern("to_json"), 0);
  char *result = lipgloss_join_vertical(NUM2DBL(position), StringValueCStr(json_str));
  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

static VALUE lipgloss_width_rb(VALUE self, VALUE string) {
  Check_Type(string, T_STRING);

  return INT2NUM(lipgloss_width(StringValueCStr(string)));
}

static VALUE lipgloss_height_rb(VALUE self, VALUE string) {
  Check_Type(string, T_STRING);

  return INT2NUM(lipgloss_height(StringValueCStr(string)));
}

static VALUE lipgloss_size_rb(VALUE self, VALUE string) {
  Check_Type(string, T_STRING);
  char *string_cstr = StringValueCStr(string);

  VALUE width = INT2NUM(lipgloss_width(string_cstr));
  VALUE height = INT2NUM(lipgloss_height(string_cstr));

  return rb_ary_new_from_args(2, width, height);
}

static VALUE lipgloss_place_rb(int argc, VALUE *argv, VALUE self) {
  VALUE width, height, horizontal_position, vertical_position, string;
  rb_scan_args(argc, argv, "5", &width, &height, &horizontal_position, &vertical_position, &string);

  Check_Type(string, T_STRING);

  char *result = lipgloss_place(
    NUM2INT(width),
    NUM2INT(height),
    NUM2DBL(horizontal_position),
    NUM2DBL(vertical_position),
    StringValueCStr(string)
  );

  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

static VALUE lipgloss_place_horizontal_rb(VALUE self, VALUE width, VALUE position, VALUE string) {
  Check_Type(string, T_STRING);

  char *result = lipgloss_place_horizontal(
    NUM2INT(width),
    NUM2DBL(position),
    StringValueCStr(string)
  );

  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

static VALUE lipgloss_place_vertical_rb(VALUE self, VALUE height, VALUE position, VALUE string) {
  Check_Type(string, T_STRING);

  char *result = lipgloss_place_vertical(
    NUM2INT(height),
    NUM2DBL(position),
    StringValueCStr(string)
  );

  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

static VALUE lipgloss_has_dark_background_rb(VALUE self) {
  return lipgloss_has_dark_background() ? Qtrue : Qfalse;
}

static VALUE lipgloss_upstream_version_rb(VALUE self) {
  char *version = lipgloss_upstream_version();
  VALUE rb_version = rb_utf8_str_new_cstr(version);

  lipgloss_free(version);

  return rb_version;
}

static VALUE lipgloss_version_rb(VALUE self) {
  VALUE gem_version = rb_const_get(self, rb_intern("VERSION"));
  VALUE upstream_version = lipgloss_upstream_version_rb(self);
  VALUE format_string = rb_utf8_str_new_cstr("lipgloss v%s (upstream v%s) [Go native extension]");

  return rb_funcall(rb_mKernel, rb_intern("sprintf"), 3, format_string, gem_version, upstream_version);
}

__attribute__((__visibility__("default"))) void Init_lipgloss(void) {
  rb_require("json");

  mLipgloss = rb_define_module("Lipgloss");

  Init_lipgloss_style();
  Init_lipgloss_table();
  Init_lipgloss_list();
  Init_lipgloss_tree();

  rb_define_singleton_method(mLipgloss, "join_horizontal", lipgloss_join_horizontal_rb, 2);
  rb_define_singleton_method(mLipgloss, "join_vertical", lipgloss_join_vertical_rb, 2);
  rb_define_singleton_method(mLipgloss, "width", lipgloss_width_rb, 1);
  rb_define_singleton_method(mLipgloss, "height", lipgloss_height_rb, 1);
  rb_define_singleton_method(mLipgloss, "size", lipgloss_size_rb, 1);
  rb_define_singleton_method(mLipgloss, "place", lipgloss_place_rb, -1);
  rb_define_singleton_method(mLipgloss, "place_horizontal", lipgloss_place_horizontal_rb, 3);
  rb_define_singleton_method(mLipgloss, "place_vertical", lipgloss_place_vertical_rb, 3);
  rb_define_singleton_method(mLipgloss, "has_dark_background?", lipgloss_has_dark_background_rb, 0);
  rb_define_singleton_method(mLipgloss, "upstream_version", lipgloss_upstream_version_rb, 0);
  rb_define_singleton_method(mLipgloss, "version", lipgloss_version_rb, 0);
}
