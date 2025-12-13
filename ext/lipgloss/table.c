#include "extension.h"

static void table_free(void *pointer) {
  lipgloss_table_t *table = (lipgloss_table_t *) pointer;

  if (table->handle != 0) {
    lipgloss_table_free(table->handle);
  }

  xfree(table);
}

static size_t table_memsize(const void *pointer) {
  return sizeof(lipgloss_table_t);
}

const rb_data_type_t table_type = {
  .wrap_struct_name = "Lipgloss::Table",
  .function = {
    .dmark = NULL,
    .dfree = table_free,
    .dsize = table_memsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE table_alloc(VALUE klass) {
  lipgloss_table_t *table = ALLOC(lipgloss_table_t);
  table->handle = lipgloss_table_new();
  return TypedData_Wrap_Struct(klass, &table_type, table);
}

VALUE table_wrap(VALUE klass, unsigned long long handle) {
  lipgloss_table_t *table = ALLOC(lipgloss_table_t);
  table->handle = handle;
  return TypedData_Wrap_Struct(klass, &table_type, table);
}

static VALUE table_initialize(VALUE self) {
  return self;
}

static VALUE table_headers(VALUE self, VALUE headers) {
  GET_TABLE(self, table);
  Check_Type(headers, T_ARRAY);

  VALUE json_str = rb_funcall(headers, rb_intern("to_json"), 0);
  unsigned long long new_handle = lipgloss_table_headers(table->handle, StringValueCStr(json_str));
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_row(VALUE self, VALUE row) {
  GET_TABLE(self, table);
  Check_Type(row, T_ARRAY);

  VALUE json_str = rb_funcall(row, rb_intern("to_json"), 0);
  unsigned long long new_handle = lipgloss_table_row(table->handle, StringValueCStr(json_str));
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_rows(VALUE self, VALUE rows) {
  GET_TABLE(self, table);
  Check_Type(rows, T_ARRAY);

  VALUE json_str = rb_funcall(rows, rb_intern("to_json"), 0);
  unsigned long long new_handle = lipgloss_table_rows(table->handle, StringValueCStr(json_str));

  return table_wrap(rb_class_of(self), new_handle);
}

static int symbol_to_table_border_type(VALUE symbol) {
  if (symbol == ID2SYM(rb_intern("normal"))) return BORDER_NORMAL;
  if (symbol == ID2SYM(rb_intern("rounded"))) return BORDER_ROUNDED;
  if (symbol == ID2SYM(rb_intern("thick"))) return BORDER_THICK;
  if (symbol == ID2SYM(rb_intern("double"))) return BORDER_DOUBLE;
  if (symbol == ID2SYM(rb_intern("hidden"))) return BORDER_HIDDEN;
  if (symbol == ID2SYM(rb_intern("block"))) return BORDER_BLOCK;
  if (symbol == ID2SYM(rb_intern("outer_half_block"))) return BORDER_OUTER_HALF_BLOCK;
  if (symbol == ID2SYM(rb_intern("inner_half_block"))) return BORDER_INNER_HALF_BLOCK;
  if (symbol == ID2SYM(rb_intern("ascii"))) return BORDER_ASCII;
  if (symbol == ID2SYM(rb_intern("markdown"))) return BORDER_MARKDOWN;

  return BORDER_NORMAL;
}

static VALUE table_border(VALUE self, VALUE border_sym) {
  GET_TABLE(self, table);
  int border_type = symbol_to_table_border_type(border_sym);
  unsigned long long new_handle = lipgloss_table_border(table->handle, border_type);

  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_style(VALUE self, VALUE style_object) {
  GET_TABLE(self, table);
  lipgloss_style_t *style;

  TypedData_Get_Struct(style_object, lipgloss_style_t, &style_type, style);
  unsigned long long new_handle = lipgloss_table_border_style(table->handle, style->handle);

  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_top(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_border_top(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_bottom(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_border_bottom(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_left(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_border_left(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_right(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_border_right(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_header(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_border_header(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_column(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_border_column(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_border_row_m(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_border_row(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_width(VALUE self, VALUE width) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_width(table->handle, NUM2INT(width));
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_height(VALUE self, VALUE height) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_height(table->handle, NUM2INT(height));
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_offset(VALUE self, VALUE offset) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_offset(table->handle, NUM2INT(offset));
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_wrap_m(VALUE self, VALUE value) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_wrap(table->handle, RTEST(value) ? 1 : 0);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_clear_rows(VALUE self) {
  GET_TABLE(self, table);
  unsigned long long new_handle = lipgloss_table_clear_rows(table->handle);
  return table_wrap(rb_class_of(self), new_handle);
}

static VALUE table_render(VALUE self) {
  GET_TABLE(self, table);
  char *result = lipgloss_table_render(table->handle);
  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

static VALUE table_to_s(VALUE self) {
  return table_render(self);
}

// Apply a pre-computed style map: { "row,col" => style_handle, ... }
static VALUE table_style_func_map(VALUE self, VALUE style_map) {
  GET_TABLE(self, table);
  Check_Type(style_map, T_HASH);

  VALUE json_hash = rb_hash_new();
  VALUE keys = rb_funcall(style_map, rb_intern("keys"), 0);

  long length = RARRAY_LEN(keys);

  for (long index = 0; index < length; index++) {
    VALUE key = rb_ary_entry(keys, index);
    VALUE style_object = rb_hash_aref(style_map, key);

    lipgloss_style_t *style;
    TypedData_Get_Struct(style_object, lipgloss_style_t, &style_type, style);

    rb_hash_aset(json_hash, key, ULL2NUM(style->handle));
  }

  VALUE json_str = rb_funcall(json_hash, rb_intern("to_json"), 0);
  unsigned long long new_handle = lipgloss_table_style_func(table->handle, StringValueCStr(json_str));

  return table_wrap(rb_class_of(self), new_handle);
}

void Init_lipgloss_table(void) {
  cTable = rb_define_class_under(mLipgloss, "Table", rb_cObject);

  rb_define_alloc_func(cTable, table_alloc);

  rb_define_method(cTable, "initialize", table_initialize, 0);
  rb_define_method(cTable, "headers", table_headers, 1);
  rb_define_method(cTable, "row", table_row, 1);
  rb_define_method(cTable, "rows", table_rows, 1);
  rb_define_method(cTable, "border", table_border, 1);
  rb_define_method(cTable, "border_style", table_border_style, 1);
  rb_define_method(cTable, "border_top", table_border_top, 1);
  rb_define_method(cTable, "border_bottom", table_border_bottom, 1);
  rb_define_method(cTable, "border_left", table_border_left, 1);
  rb_define_method(cTable, "border_right", table_border_right, 1);
  rb_define_method(cTable, "border_header", table_border_header, 1);
  rb_define_method(cTable, "border_column", table_border_column, 1);
  rb_define_method(cTable, "border_row", table_border_row_m, 1);
  rb_define_method(cTable, "width", table_width, 1);
  rb_define_method(cTable, "height", table_height, 1);
  rb_define_method(cTable, "offset", table_offset, 1);
  rb_define_method(cTable, "wrap", table_wrap_m, 1);
  rb_define_method(cTable, "clear_rows", table_clear_rows, 0);
  rb_define_method(cTable, "_style_func_map", table_style_func_map, 1);
  rb_define_method(cTable, "render", table_render, 0);
  rb_define_method(cTable, "to_s", table_to_s, 0);
}
