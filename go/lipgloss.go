package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"github.com/charmbracelet/lipgloss"
	lipglosslist "github.com/charmbracelet/lipgloss/list"
	lipglosstable "github.com/charmbracelet/lipgloss/table"
	lipglosstree "github.com/charmbracelet/lipgloss/tree"
	"runtime/debug"
	"sync"
	"unsafe"
)

// Shared ID counter for all handle types
var (
	nextID   uint64 = 1
	nextIDMu sync.Mutex
)

func getNextID() uint64 {
	nextIDMu.Lock()
	defer nextIDMu.Unlock()
	id := nextID
	nextID++
	return id
}

// Style storage
var (
	styles   = make(map[uint64]lipgloss.Style)
	stylesMu sync.RWMutex
)

// Table storage
var (
	tables   = make(map[uint64]*lipglosstable.Table)
	tablesMu sync.RWMutex
)

// List storage
var (
	lists   = make(map[uint64]*lipglosslist.List)
	listsMu sync.RWMutex
)

// Tree storage
var (
	trees   = make(map[uint64]*lipglosstree.Tree)
	treesMu sync.RWMutex
)

//export lipgloss_free
func lipgloss_free(pointer *C.char) {
	C.free(unsafe.Pointer(pointer))
}

//export lipgloss_upstream_version
func lipgloss_upstream_version() *C.char {
	info, ok := debug.ReadBuildInfo()

	if !ok {
		return C.CString("unknown")
	}

	for _, dep := range info.Deps {
		if dep.Path == "github.com/charmbracelet/lipgloss" {
			return C.CString(dep.Version)
		}
	}

	return C.CString("unknown")
}

func main() {}
