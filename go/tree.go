package main

import "C"

import (
	"encoding/json"
	lipglosstree "github.com/charmbracelet/lipgloss/tree"
)

func allocTree(tree *lipglosstree.Tree) uint64 {
	treesMu.Lock()
	defer treesMu.Unlock()
	id := getNextID()
	trees[id] = tree

	return id
}

func getTree(id uint64) *lipglosstree.Tree {
	treesMu.RLock()
	defer treesMu.RUnlock()

	return trees[id]
}

//export lipgloss_tree_new
func lipgloss_tree_new() C.ulonglong {
	return C.ulonglong(allocTree(lipglosstree.New()))
}

//export lipgloss_tree_root
func lipgloss_tree_root(root *C.char) C.ulonglong {
	return C.ulonglong(allocTree(lipglosstree.Root(C.GoString(root))))
}

//export lipgloss_tree_free
func lipgloss_tree_free(id C.ulonglong) {
	treesMu.Lock()
	defer treesMu.Unlock()
	delete(trees, uint64(id))
}

//export lipgloss_tree_set_root
func lipgloss_tree_set_root(id C.ulonglong, root *C.char) C.ulonglong {
	tree := getTree(uint64(id)).Root(C.GoString(root))

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_child
func lipgloss_tree_child(id C.ulonglong, child *C.char) C.ulonglong {
	tree := getTree(uint64(id)).Child(C.GoString(child))

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_child_tree
func lipgloss_tree_child_tree(id C.ulonglong, childTreeID C.ulonglong) C.ulonglong {
	childTree := getTree(uint64(childTreeID))
	tree := getTree(uint64(id)).Child(childTree)

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_children
func lipgloss_tree_children(id C.ulonglong, childrenJSON *C.char) C.ulonglong {
	var children []string

	if err := json.Unmarshal([]byte(C.GoString(childrenJSON)), &children); err != nil {
		return id
	}

	anyChildren := make([]any, len(children))

	for index, child := range children {
		anyChildren[index] = child
	}

	tree := getTree(uint64(id)).Child(anyChildren...)

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_enumerator
func lipgloss_tree_enumerator(id C.ulonglong, enumType C.int) C.ulonglong {
	var enumerator lipglosstree.Enumerator

	switch int(enumType) {
	case 0:
		enumerator = lipglosstree.DefaultEnumerator
	case 1:
		enumerator = lipglosstree.RoundedEnumerator
	default:
		enumerator = lipglosstree.DefaultEnumerator
	}

	tree := getTree(uint64(id)).Enumerator(enumerator)

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_enumerator_style
func lipgloss_tree_enumerator_style(id C.ulonglong, styleID C.ulonglong) C.ulonglong {
	style := getStyle(uint64(styleID))
	tree := getTree(uint64(id)).EnumeratorStyle(style)

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_item_style
func lipgloss_tree_item_style(id C.ulonglong, styleID C.ulonglong) C.ulonglong {
	style := getStyle(uint64(styleID))
	tree := getTree(uint64(id)).ItemStyle(style)

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_root_style
func lipgloss_tree_root_style(id C.ulonglong, styleID C.ulonglong) C.ulonglong {
	style := getStyle(uint64(styleID))
	tree := getTree(uint64(id)).RootStyle(style)

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_offset
func lipgloss_tree_offset(id C.ulonglong, start C.int, end C.int) C.ulonglong {
	tree := getTree(uint64(id)).Offset(int(start), int(end))

	return C.ulonglong(allocTree(tree))
}

//export lipgloss_tree_render
func lipgloss_tree_render(id C.ulonglong) *C.char {
	tree := getTree(uint64(id))

	return C.CString(tree.String())
}
