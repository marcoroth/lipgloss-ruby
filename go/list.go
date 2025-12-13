package main

import "C"

import (
	"encoding/json"
	lipglosslist "github.com/charmbracelet/lipgloss/list"
)

func allocList(list *lipglosslist.List) uint64 {
	listsMu.Lock()
	defer listsMu.Unlock()
	id := getNextID()
	lists[id] = list

	return id
}

func getList(id uint64) *lipglosslist.List {
	listsMu.RLock()
	defer listsMu.RUnlock()

	return lists[id]
}

//export lipgloss_list_new
func lipgloss_list_new() C.ulonglong {
	return C.ulonglong(allocList(lipglosslist.New()))
}

//export lipgloss_list_free
func lipgloss_list_free(id C.ulonglong) {
	listsMu.Lock()
	defer listsMu.Unlock()
	delete(lists, uint64(id))
}

//export lipgloss_list_item
func lipgloss_list_item(id C.ulonglong, item *C.char) C.ulonglong {
	list := getList(uint64(id)).Item(C.GoString(item))
	return C.ulonglong(allocList(list))
}

//export lipgloss_list_item_list
func lipgloss_list_item_list(id C.ulonglong, sublistID C.ulonglong) C.ulonglong {
	sublist := getList(uint64(sublistID))
	list := getList(uint64(id)).Item(sublist)

	return C.ulonglong(allocList(list))
}

//export lipgloss_list_items
func lipgloss_list_items(id C.ulonglong, itemsJSON *C.char) C.ulonglong {
	var items []string

	if err := json.Unmarshal([]byte(C.GoString(itemsJSON)), &items); err != nil {
		return id
	}

	anyItems := make([]any, len(items))

	for index, item := range items {
		anyItems[index] = item
	}

	list := getList(uint64(id)).Items(anyItems...)

	return C.ulonglong(allocList(list))
}

//export lipgloss_list_enumerator
func lipgloss_list_enumerator(id C.ulonglong, enumType C.int) C.ulonglong {
	var enumerator lipglosslist.Enumerator

	switch int(enumType) {
	case 0:
		enumerator = lipglosslist.Bullet
	case 1:
		enumerator = lipglosslist.Arabic
	case 2:
		enumerator = lipglosslist.Alphabet
	case 3:
		enumerator = lipglosslist.Roman
	case 4:
		enumerator = lipglosslist.Dash
	case 5:
		enumerator = lipglosslist.Asterisk
	default:
		enumerator = lipglosslist.Bullet
	}

	list := getList(uint64(id)).Enumerator(enumerator)

	return C.ulonglong(allocList(list))
}

//export lipgloss_list_enumerator_style
func lipgloss_list_enumerator_style(id C.ulonglong, styleID C.ulonglong) C.ulonglong {
	style := getStyle(uint64(styleID))
	list := getList(uint64(id)).EnumeratorStyle(style)

	return C.ulonglong(allocList(list))
}

//export lipgloss_list_item_style
func lipgloss_list_item_style(id C.ulonglong, styleID C.ulonglong) C.ulonglong {
	style := getStyle(uint64(styleID))
	list := getList(uint64(id)).ItemStyle(style)

	return C.ulonglong(allocList(list))
}

//export lipgloss_list_render
func lipgloss_list_render(id C.ulonglong) *C.char {
	list := getList(uint64(id))

	return C.CString(list.String())
}
