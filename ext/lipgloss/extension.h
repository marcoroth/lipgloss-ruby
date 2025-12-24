#ifndef LIPGLOSS_EXTENSION_H
#define LIPGLOSS_EXTENSION_H

#include <ruby.h>
#include "liblipgloss.h"

extern VALUE mLipgloss;
extern VALUE cStyle;
extern VALUE cTable;
extern VALUE cList;
extern VALUE cTree;

extern const rb_data_type_t style_type;
extern const rb_data_type_t table_type;
extern const rb_data_type_t list_type;
extern const rb_data_type_t tree_type;

typedef struct {
  unsigned long long handle;
} lipgloss_style_t;

typedef struct {
  unsigned long long handle;
} lipgloss_table_t;

typedef struct {
  unsigned long long handle;
} lipgloss_list_t;

typedef struct {
  unsigned long long handle;
} lipgloss_tree_t;


#define GET_STYLE(self, style) \
  lipgloss_style_t *style; \
  TypedData_Get_Struct(self, lipgloss_style_t, &style_type, style)

#define GET_TABLE(self, table) \
  lipgloss_table_t *table; \
  TypedData_Get_Struct(self, lipgloss_table_t, &table_type, table)

#define GET_LIST(self, list) \
  lipgloss_list_t *list; \
  TypedData_Get_Struct(self, lipgloss_list_t, &list_type, list)

#define GET_TREE(self, tree) \
  lipgloss_tree_t *tree; \
  TypedData_Get_Struct(self, lipgloss_tree_t, &tree_type, tree)

#define BORDER_NORMAL 0
#define BORDER_ROUNDED 1
#define BORDER_THICK 2
#define BORDER_DOUBLE 3
#define BORDER_HIDDEN 4
#define BORDER_BLOCK 5
#define BORDER_OUTER_HALF_BLOCK 6
#define BORDER_INNER_HALF_BLOCK 7
#define BORDER_ASCII 8
#define BORDER_MARKDOWN 9

VALUE style_wrap(VALUE klass, unsigned long long handle);
VALUE table_wrap(VALUE klass, unsigned long long handle);
VALUE list_wrap_handle(VALUE klass, unsigned long long handle);
VALUE tree_wrap_handle(VALUE klass, unsigned long long handle);

void Init_lipgloss_style(void);
void Init_lipgloss_table(void);
void Init_lipgloss_list(void);
void Init_lipgloss_tree(void);
void Init_lipgloss_color(void);

void register_style_spacing_methods(void);
void register_style_border_methods(void);
void register_style_unset_methods(void);

int is_adaptive_color(VALUE object);

#endif
