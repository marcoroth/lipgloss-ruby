#include "extension.h"

VALUE mColor;

#define BLEND_LUV 0
#define BLEND_RGB 1
#define BLEND_HCL 2

static int blend_mode_from_symbol(VALUE mode) {
  if (NIL_P(mode)) {
    return BLEND_LUV;
  }

  ID mode_id = SYM2ID(mode);

  if (mode_id == rb_intern("luv")) {
    return BLEND_LUV;
  } else if (mode_id == rb_intern("rgb")) {
    return BLEND_RGB;
  } else if (mode_id == rb_intern("hcl")) {
    return BLEND_HCL;
  }

  return BLEND_LUV;
}

static VALUE color_blend(int argc, VALUE *argv, VALUE self) {
  VALUE c1, c2, t, opts;
  rb_scan_args(argc, argv, "3:", &c1, &c2, &t, &opts);

  Check_Type(c1, T_STRING);
  Check_Type(c2, T_STRING);

  VALUE mode = Qnil;
  if (!NIL_P(opts)) {
    mode = rb_hash_aref(opts, ID2SYM(rb_intern("mode")));
  }

  int blend_mode = blend_mode_from_symbol(mode);
  char *result;

  switch (blend_mode) {
    case BLEND_RGB:
      result = lipgloss_color_blend_rgb(StringValueCStr(c1), StringValueCStr(c2), NUM2DBL(t));
      break;
    case BLEND_HCL:
      result = lipgloss_color_blend_hcl(StringValueCStr(c1), StringValueCStr(c2), NUM2DBL(t));
      break;
    default:
      result = lipgloss_color_blend_luv(StringValueCStr(c1), StringValueCStr(c2), NUM2DBL(t));
      break;
  }

  VALUE rb_result = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);

  return rb_result;
}

static VALUE color_blend_luv(VALUE self, VALUE c1, VALUE c2, VALUE t) {
  Check_Type(c1, T_STRING);
  Check_Type(c2, T_STRING);

  char *result = lipgloss_color_blend_luv(StringValueCStr(c1), StringValueCStr(c2), NUM2DBL(t));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);

  return rb_result;
}

static VALUE color_blend_rgb(VALUE self, VALUE c1, VALUE c2, VALUE t) {
  Check_Type(c1, T_STRING);
  Check_Type(c2, T_STRING);

  char *result = lipgloss_color_blend_rgb(StringValueCStr(c1), StringValueCStr(c2), NUM2DBL(t));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);

  return rb_result;
}

static VALUE color_blend_hcl(VALUE self, VALUE c1, VALUE c2, VALUE t) {
  Check_Type(c1, T_STRING);
  Check_Type(c2, T_STRING);

  char *result = lipgloss_color_blend_hcl(StringValueCStr(c1), StringValueCStr(c2), NUM2DBL(t));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);

  return rb_result;
}

static VALUE color_blends(int argc, VALUE *argv, VALUE self) {
  VALUE c1, c2, steps, opts;
  rb_scan_args(argc, argv, "3:", &c1, &c2, &steps, &opts);

  Check_Type(c1, T_STRING);
  Check_Type(c2, T_STRING);

  VALUE mode = Qnil;
  if (!NIL_P(opts)) {
    mode = rb_hash_aref(opts, ID2SYM(rb_intern("mode")));
  }

  int blend_mode = blend_mode_from_symbol(mode);
  char *result = lipgloss_color_blends(StringValueCStr(c1), StringValueCStr(c2), NUM2INT(steps), blend_mode);
  VALUE json_string = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);

  return rb_funcall(rb_const_get(rb_cObject, rb_intern("JSON")), rb_intern("parse"), 1, json_string);
}

static VALUE color_grid(int argc, VALUE *argv, VALUE self) {
  VALUE x0y0, x1y0, x0y1, x1y1, x_steps, y_steps, opts;
  rb_scan_args(argc, argv, "6:", &x0y0, &x1y0, &x0y1, &x1y1, &x_steps, &y_steps, &opts);

  Check_Type(x0y0, T_STRING);
  Check_Type(x1y0, T_STRING);
  Check_Type(x0y1, T_STRING);
  Check_Type(x1y1, T_STRING);

  VALUE mode = Qnil;
  if (!NIL_P(opts)) {
    mode = rb_hash_aref(opts, ID2SYM(rb_intern("mode")));
  }

  int blend_mode = blend_mode_from_symbol(mode);

  char *result = lipgloss_color_grid(
    StringValueCStr(x0y0),
    StringValueCStr(x1y0),
    StringValueCStr(x0y1),
    StringValueCStr(x1y1),
    NUM2INT(x_steps),
    NUM2INT(y_steps),
    blend_mode
  );

  VALUE json_string = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);

  return rb_funcall(rb_const_get(rb_cObject, rb_intern("JSON")), rb_intern("parse"), 1, json_string);
}

void Init_lipgloss_color(void) {
  VALUE mColorBlend = rb_define_module_under(mLipgloss, "ColorBlend");

  rb_define_singleton_method(mColorBlend, "blend", color_blend, -1);
  rb_define_singleton_method(mColorBlend, "blend_luv", color_blend_luv, 3);
  rb_define_singleton_method(mColorBlend, "blend_rgb", color_blend_rgb, 3);
  rb_define_singleton_method(mColorBlend, "blend_hcl", color_blend_hcl, 3);
  rb_define_singleton_method(mColorBlend, "blends", color_blends, -1);
  rb_define_singleton_method(mColorBlend, "grid", color_grid, -1);

  rb_define_const(mColorBlend, "LUV", ID2SYM(rb_intern("luv")));
  rb_define_const(mColorBlend, "RGB", ID2SYM(rb_intern("rgb")));
  rb_define_const(mColorBlend, "HCL", ID2SYM(rb_intern("hcl")));
}
