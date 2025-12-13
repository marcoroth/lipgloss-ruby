#include "extension.h"

static void tree_free(void *pointer) {
  lipgloss_tree_t *tree = (lipgloss_tree_t *) pointer;

  if (tree->handle != 0) {
    lipgloss_tree_free(tree->handle);
  }

  xfree(tree);
}

static size_t tree_memsize(const void *pointer) {
  return sizeof(lipgloss_tree_t);
}

const rb_data_type_t tree_type = {
  .wrap_struct_name = "Lipgloss::Tree",
  .function = {
    .dmark = NULL,
    .dfree = tree_free,
    .dsize = tree_memsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE tree_alloc(VALUE klass) {
  lipgloss_tree_t *tree = ALLOC(lipgloss_tree_t);
  tree->handle = lipgloss_tree_new();

  return TypedData_Wrap_Struct(klass, &tree_type, tree);
}

VALUE tree_wrap_handle(VALUE klass, unsigned long long handle) {
  lipgloss_tree_t *tree = ALLOC(lipgloss_tree_t);
  tree->handle = handle;

  return TypedData_Wrap_Struct(klass, &tree_type, tree);
}

static VALUE tree_initialize(int argc, VALUE *argv, VALUE self) {
  if (argc == 1) {
    GET_TREE(self, tree);
    VALUE root = argv[0];
    Check_Type(root, T_STRING);
    tree->handle = lipgloss_tree_set_root(tree->handle, StringValueCStr(root));
  }

  return self;
}

static VALUE tree_root_m(VALUE klass, VALUE root) {
  Check_Type(root, T_STRING);
  unsigned long long handle = lipgloss_tree_root(StringValueCStr(root));

  return tree_wrap_handle(klass, handle);
}

static VALUE tree_set_root(VALUE self, VALUE root) {
  GET_TREE(self, tree);
  Check_Type(root, T_STRING);
  unsigned long long new_handle = lipgloss_tree_set_root(tree->handle, StringValueCStr(root));

  return tree_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE tree_child(int argc, VALUE *argv, VALUE self) {
  GET_TREE(self, tree);

  if (argc == 0) {
    rb_raise(rb_eArgError, "wrong number of arguments (given 0, expected 1+)");
  }

  VALUE result = self;
  for (int index = 0; index < argc; index++) {
    lipgloss_tree_t *current;
    TypedData_Get_Struct(result, lipgloss_tree_t, &tree_type, current);

    VALUE child = argv[index];

    if (rb_obj_is_kind_of(child, cTree)) {
      lipgloss_tree_t *subtree;
      TypedData_Get_Struct(child, lipgloss_tree_t, &tree_type, subtree);
      unsigned long long new_handle = lipgloss_tree_child_tree(current->handle, subtree->handle);
      result = tree_wrap_handle(rb_class_of(self), new_handle);
    } else {
      Check_Type(child, T_STRING);
      unsigned long long new_handle = lipgloss_tree_child(current->handle, StringValueCStr(child));
      result = tree_wrap_handle(rb_class_of(self), new_handle);
    }
  }

  return result;
}

static VALUE tree_children(VALUE self, VALUE children) {
  GET_TREE(self, tree);
  Check_Type(children, T_ARRAY);

  VALUE json_str = rb_funcall(children, rb_intern("to_json"), 0);
  unsigned long long new_handle = lipgloss_tree_children(tree->handle, StringValueCStr(json_str));

  return tree_wrap_handle(rb_class_of(self), new_handle);
}

#define TREE_ENUMERATOR_DEFAULT 0
#define TREE_ENUMERATOR_ROUNDED 1

static int symbol_to_tree_enumerator(VALUE symbol) {
  if (symbol == ID2SYM(rb_intern("default"))) return TREE_ENUMERATOR_DEFAULT;
  if (symbol == ID2SYM(rb_intern("rounded"))) return TREE_ENUMERATOR_ROUNDED;

  return TREE_ENUMERATOR_DEFAULT;
}

static VALUE tree_enumerator(VALUE self, VALUE enum_symbol) {
  GET_TREE(self, tree);
  int enum_type = symbol_to_tree_enumerator(enum_symbol);
  unsigned long long new_handle = lipgloss_tree_enumerator(tree->handle, enum_type);

  return tree_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE tree_enumerator_style(VALUE self, VALUE style_object) {
  GET_TREE(self, tree);
  lipgloss_style_t *style;

  TypedData_Get_Struct(style_object, lipgloss_style_t, &style_type, style);
  unsigned long long new_handle = lipgloss_tree_enumerator_style(tree->handle, style->handle);

  return tree_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE tree_item_style(VALUE self, VALUE style_object) {
  GET_TREE(self, tree);
  lipgloss_style_t *style;

  TypedData_Get_Struct(style_object, lipgloss_style_t, &style_type, style);
  unsigned long long new_handle = lipgloss_tree_item_style(tree->handle, style->handle);

  return tree_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE tree_root_style(VALUE self, VALUE style_object) {
  GET_TREE(self, tree);
  lipgloss_style_t *style;

  TypedData_Get_Struct(style_object, lipgloss_style_t, &style_type, style);
  unsigned long long new_handle = lipgloss_tree_root_style(tree->handle, style->handle);

  return tree_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE tree_offset(VALUE self, VALUE start, VALUE end) {
  GET_TREE(self, tree);
  unsigned long long new_handle = lipgloss_tree_offset(tree->handle, NUM2INT(start), NUM2INT(end));

  return tree_wrap_handle(rb_class_of(self), new_handle);
}

static VALUE tree_render(VALUE self) {
  GET_TREE(self, tree);
  char *result = lipgloss_tree_render(tree->handle);
  VALUE rb_result = rb_utf8_str_new_cstr(result);

  lipgloss_free(result);

  return rb_result;
}

static VALUE tree_to_s(VALUE self) {
  return tree_render(self);
}

void Init_lipgloss_tree(void) {
  cTree = rb_define_class_under(mLipgloss, "Tree", rb_cObject);

  rb_define_alloc_func(cTree, tree_alloc);
  rb_define_singleton_method(cTree, "root", tree_root_m, 1);

  rb_define_method(cTree, "initialize", tree_initialize, -1);
  rb_define_method(cTree, "root=", tree_set_root, 1);
  rb_define_method(cTree, "child", tree_child, -1);
  rb_define_method(cTree, "children", tree_children, 1);
  rb_define_method(cTree, "enumerator", tree_enumerator, 1);
  rb_define_method(cTree, "enumerator_style", tree_enumerator_style, 1);
  rb_define_method(cTree, "item_style", tree_item_style, 1);
  rb_define_method(cTree, "root_style", tree_root_style, 1);
  rb_define_method(cTree, "offset", tree_offset, 2);
  rb_define_method(cTree, "render", tree_render, 0);
  rb_define_method(cTree, "to_s", tree_to_s, 0);
}
