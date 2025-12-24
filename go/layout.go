package main

import "C"

import (
	"encoding/json"
	"github.com/charmbracelet/lipgloss"
)

//export lipgloss_join_horizontal
func lipgloss_join_horizontal(position C.double, stringsJSON *C.char) *C.char {
	var strings []string

	if err := json.Unmarshal([]byte(C.GoString(stringsJSON)), &strings); err != nil {
		return C.CString("")
	}

	result := lipgloss.JoinHorizontal(lipgloss.Position(position), strings...)

	return C.CString(result)
}

//export lipgloss_join_vertical
func lipgloss_join_vertical(position C.double, stringsJSON *C.char) *C.char {
	var strings []string

	if err := json.Unmarshal([]byte(C.GoString(stringsJSON)), &strings); err != nil {
		return C.CString("")
	}

	result := lipgloss.JoinVertical(lipgloss.Position(position), strings...)

	return C.CString(result)
}

//export lipgloss_width
func lipgloss_width(text *C.char) C.int {
	return C.int(lipgloss.Width(C.GoString(text)))
}

//export lipgloss_height
func lipgloss_height(text *C.char) C.int {
	return C.int(lipgloss.Height(C.GoString(text)))
}

//export lipgloss_place
func lipgloss_place(width C.int, height C.int, horizontalPosition C.double, verticalPosition C.double, text *C.char) *C.char {
	result := lipgloss.Place(int(width), int(height), lipgloss.Position(horizontalPosition), lipgloss.Position(verticalPosition), C.GoString(text))
	return C.CString(result)
}

//export lipgloss_place_with_whitespace
func lipgloss_place_with_whitespace(width C.int, height C.int, horizontalPosition C.double, verticalPosition C.double, text *C.char, whitespaceChars *C.char, whitespaceForeground *C.char) *C.char {
	opts := []lipgloss.WhitespaceOption{}

	wsChars := C.GoString(whitespaceChars)
	if wsChars != "" {
		opts = append(opts, lipgloss.WithWhitespaceChars(wsChars))
	}

	wsFg := C.GoString(whitespaceForeground)
	if wsFg != "" {
		opts = append(opts, lipgloss.WithWhitespaceForeground(lipgloss.Color(wsFg)))
	}

	result := lipgloss.Place(int(width), int(height), lipgloss.Position(horizontalPosition), lipgloss.Position(verticalPosition), C.GoString(text), opts...)
	return C.CString(result)
}

//export lipgloss_place_with_whitespace_adaptive
func lipgloss_place_with_whitespace_adaptive(width C.int, height C.int, horizontalPosition C.double, verticalPosition C.double, text *C.char, whitespaceChars *C.char, whitespaceForegroundLight *C.char, whitespaceForegroundDark *C.char) *C.char {
	opts := []lipgloss.WhitespaceOption{}

	wsChars := C.GoString(whitespaceChars)
	if wsChars != "" {
		opts = append(opts, lipgloss.WithWhitespaceChars(wsChars))
	}

	wsFgLight := C.GoString(whitespaceForegroundLight)
	wsFgDark := C.GoString(whitespaceForegroundDark)

	if wsFgLight != "" || wsFgDark != "" {
		opts = append(opts, lipgloss.WithWhitespaceForeground(lipgloss.AdaptiveColor{
			Light: wsFgLight,
			Dark:  wsFgDark,
		}))
	}

	result := lipgloss.Place(int(width), int(height), lipgloss.Position(horizontalPosition), lipgloss.Position(verticalPosition), C.GoString(text), opts...)

	return C.CString(result)
}

//export lipgloss_place_horizontal
func lipgloss_place_horizontal(width C.int, position C.double, text *C.char) *C.char {
	result := lipgloss.PlaceHorizontal(int(width), lipgloss.Position(position), C.GoString(text))
	return C.CString(result)
}

//export lipgloss_place_vertical
func lipgloss_place_vertical(height C.int, position C.double, text *C.char) *C.char {
	result := lipgloss.PlaceVertical(int(height), lipgloss.Position(position), C.GoString(text))
	return C.CString(result)
}

//export lipgloss_has_dark_background
func lipgloss_has_dark_background() C.int {
	if lipgloss.HasDarkBackground() {
		return 1
	}

	return 0
}
