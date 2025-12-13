#include "extension.h"

static void list_free(void *pointer) {
  lipgloss_list_t *list = (lipgloss_list_t *) pointer;

  if (list->handle != 0) {
    lipgloss_list_free(list->handle);
  }

  xfree(list);
}

static size_t list_memsize(const void *pointer) {
  return sizeof(lipgloss_list_t);
}

const rb_data_type_t list_type = {
  .wrap_struct_name = "Lipgloss::List",
  .function = {
    .dmark = NULL,
    .dfree = list_free,
    .dsize = list_memsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE list_alloc(VALUE klass) {
  lipgloss_list_t *list = ALLOC(lipgloss_list_t);
  list->handle = lipgloss_list_new();

  return TypedData_Wrap_Struct(klass, &list_type, list);
}

VALUE list_wrap_handle(VALUE klass, unsigned long long handle) {
  lipgloss_list_t *list = ALLOC(lipgloss_list_t);
  list->handle = handle;

  return TypedData_Wrap_Struct(klass, &list_type, list);
}

static VALUE list_initialize(int argc, VALUE *argv, VALUE self) {
  if (argc > 0) {
    GET_LIST(self, list);
    VALUE json_str = rb_funcall(rb_ary_new_from_values(argc, argv), rb_intern("to_json"), 0);
    list->handle = lipgloss_list_items(list->handle, StringValueCStr(json_str));
  }

  return self;
}

static VALUE list_item(VALUE self, VALUE item) {
  GET_LIST(self, list);

  if (rb_obj_is_kind_of(item, cList)) {
    lipgloss_list_t *sublist;
    TypedData_Get_Struct(item, lipgloss_list_t, &list_type, sublist);
    unsigned long long new_handle = lipgloss_list_item_list(list->handle, sublist->handle);

    return list_wrap_handle(rb_class_of(self), new_handle);
  }

  Check_Type(item, T_STRING);
  unsigned long long new_handle = lipgloss_list_item(list->handle, StringValueCStr(item));

  return list_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE list_items(VALUE self, VALUE items) {
  GET_LIST(self, list);
  Check_Type(items, T_ARRAY);

  VALUE json_str = rb_funcall(items, rb_intern("to_json"), 0);
  unsigned long long new_handle = lipgloss_list_items(list->handle, StringValueCStr(json_str));

  return list_wrap_handle(rb_class_of(self), new_handle);
}

#define LIST_ENUMERATOR_BULLET 0
#define LIST_ENUMERATOR_ARABIC 1
#define LIST_ENUMERATOR_ALPHABET 2
#define LIST_ENUMERATOR_ROMAN 3
#define LIST_ENUMERATOR_DASH 4
#define LIST_ENUMERATOR_ASTERISK 5

static int symbol_to_list_enumerator(VALUE symbol) {
  if (symbol == ID2SYM(rb_intern("bullet"))) return LIST_ENUMERATOR_BULLET;
  if (symbol == ID2SYM(rb_intern("arabic"))) return LIST_ENUMERATOR_ARABIC;
  if (symbol == ID2SYM(rb_intern("alphabet"))) return LIST_ENUMERATOR_ALPHABET;
  if (symbol == ID2SYM(rb_intern("roman"))) return LIST_ENUMERATOR_ROMAN;
  if (symbol == ID2SYM(rb_intern("dash"))) return LIST_ENUMERATOR_DASH;
  if (symbol == ID2SYM(rb_intern("asterisk"))) return LIST_ENUMERATOR_ASTERISK;

  return LIST_ENUMERATOR_BULLET;
}

static VALUE list_enumerator(VALUE self, VALUE enum_symbol) {
  GET_LIST(self, list);
  int enum_type = symbol_to_list_enumerator(enum_symbol);
  unsigned long long new_handle = lipgloss_list_enumerator(list->handle, enum_type);

  return list_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE list_enumerator_style(VALUE self, VALUE style_object) {
  GET_LIST(self, list);
  lipgloss_style_t *style;

  TypedData_Get_Struct(style_object, lipgloss_style_t, &style_type, style);
  unsigned long long new_handle = lipgloss_list_enumerator_style(list->handle, style->handle);

  return list_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE list_item_style(VALUE self, VALUE style_object) {
  GET_LIST(self, list);
  lipgloss_style_t *style;
  TypedData_Get_Struct(style_object, lipgloss_style_t, &style_type, style);
  unsigned long long new_handle = lipgloss_list_item_style(list->handle, style->handle);
  return list_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE list_render(VALUE self) {
  GET_LIST(self, list);
  char *result = lipgloss_list_render(list->handle);
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  lipgloss_free(result);
  return rb_result;
}

static VALUE list_to_s(VALUE self) {
  return list_render(self);
}

void Init_lipgloss_list(void) {
  cList = rb_define_class_under(mLipgloss, "List", rb_cObject);

  rb_define_alloc_func(cList, list_alloc);

  rb_define_method(cList, "initialize", list_initialize, -1);
  rb_define_method(cList, "item", list_item, 1);
  rb_define_method(cList, "items", list_items, 1);
  rb_define_method(cList, "enumerator", list_enumerator, 1);
  rb_define_method(cList, "enumerator_style", list_enumerator_style, 1);
  rb_define_method(cList, "item_style", list_item_style, 1);
  rb_define_method(cList, "render", list_render, 0);
  rb_define_method(cList, "to_s", list_to_s, 0);
}
