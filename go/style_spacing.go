package main

import "C"

import (
	"github.com/charmbracelet/lipgloss"
	"unsafe"
)

// Padding methods

//export lipgloss_style_padding
func lipgloss_style_padding(id C.ulonglong, values *C.int, count C.int) C.ulonglong {
	goValues := make([]int, int(count))
	slice := unsafe.Slice(values, int(count))

	for index, value := range slice {
		goValues[index] = int(value)
	}

	style := getStyle(uint64(id)).Padding(goValues...)

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_padding_top
func lipgloss_style_padding_top(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).PaddingTop(int(value))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_padding_right
func lipgloss_style_padding_right(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).PaddingRight(int(value))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_padding_bottom
func lipgloss_style_padding_bottom(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).PaddingBottom(int(value))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_padding_left
func lipgloss_style_padding_left(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).PaddingLeft(int(value))
	return C.ulonglong(allocStyle(style))
}

// Margin methods

//export lipgloss_style_margin
func lipgloss_style_margin(id C.ulonglong, values *C.int, count C.int) C.ulonglong {
	goValues := make([]int, int(count))
	slice := unsafe.Slice(values, int(count))

	for index, value := range slice {
		goValues[index] = int(value)
	}

	style := getStyle(uint64(id)).Margin(goValues...)

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_margin_top
func lipgloss_style_margin_top(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).MarginTop(int(value))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_margin_right
func lipgloss_style_margin_right(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).MarginRight(int(value))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_margin_bottom
func lipgloss_style_margin_bottom(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).MarginBottom(int(value))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_margin_left
func lipgloss_style_margin_left(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).MarginLeft(int(value))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_margin_background
func lipgloss_style_margin_background(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).MarginBackground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}
