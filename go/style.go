package main

import "C"

import (
	"unsafe"

	"github.com/charmbracelet/lipgloss"
)

func allocStyle(style lipgloss.Style) uint64 {
	stylesMu.Lock()
	defer stylesMu.Unlock()
	id := getNextID()
	styles[id] = style

	return id
}

func getStyle(id uint64) lipgloss.Style {
	stylesMu.RLock()
	defer stylesMu.RUnlock()

	return styles[id]
}

//export lipgloss_new_style
func lipgloss_new_style() C.ulonglong {
	return C.ulonglong(allocStyle(lipgloss.NewStyle()))
}

//export lipgloss_free_style
func lipgloss_free_style(id C.ulonglong) {
	stylesMu.Lock()
	defer stylesMu.Unlock()
	delete(styles, uint64(id))
}

//export lipgloss_style_render
func lipgloss_style_render(id C.ulonglong, text *C.char) *C.char {
	style := getStyle(uint64(id))
	result := style.Render(C.GoString(text))

	return C.CString(result)
}

// Text formatting methods

//export lipgloss_style_bold
func lipgloss_style_bold(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Bold(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_italic
func lipgloss_style_italic(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Italic(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_underline
func lipgloss_style_underline(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Underline(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_strikethrough
func lipgloss_style_strikethrough(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Strikethrough(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_reverse
func lipgloss_style_reverse(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Reverse(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_blink
func lipgloss_style_blink(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Blink(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_faint
func lipgloss_style_faint(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Faint(value != 0)
	return C.ulonglong(allocStyle(style))
}

// Color methods

//export lipgloss_style_foreground
func lipgloss_style_foreground(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Foreground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_background
func lipgloss_style_background(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Background(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_foreground_adaptive
func lipgloss_style_foreground_adaptive(id C.ulonglong, light *C.char, dark *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Foreground(lipgloss.AdaptiveColor{
		Light: C.GoString(light),
		Dark:  C.GoString(dark),
	})

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_background_adaptive
func lipgloss_style_background_adaptive(id C.ulonglong, light *C.char, dark *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Background(lipgloss.AdaptiveColor{
		Light: C.GoString(light),
		Dark:  C.GoString(dark),
	})

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_foreground_complete
func lipgloss_style_foreground_complete(id C.ulonglong, trueColor *C.char, ansi256 *C.char, ansi *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Foreground(lipgloss.CompleteColor{
		TrueColor: C.GoString(trueColor),
		ANSI256:   C.GoString(ansi256),
		ANSI:      C.GoString(ansi),
	})

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_background_complete
func lipgloss_style_background_complete(id C.ulonglong, trueColor *C.char, ansi256 *C.char, ansi *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Background(lipgloss.CompleteColor{
		TrueColor: C.GoString(trueColor),
		ANSI256:   C.GoString(ansi256),
		ANSI:      C.GoString(ansi),
	})

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_foreground_complete_adaptive
func lipgloss_style_foreground_complete_adaptive(id C.ulonglong, lightTrue *C.char, lightAnsi256 *C.char, lightAnsi *C.char, darkTrue *C.char, darkAnsi256 *C.char, darkAnsi *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Foreground(lipgloss.CompleteAdaptiveColor{
		Light: lipgloss.CompleteColor{
			TrueColor: C.GoString(lightTrue),
			ANSI256:   C.GoString(lightAnsi256),
			ANSI:      C.GoString(lightAnsi),
		},
		Dark: lipgloss.CompleteColor{
			TrueColor: C.GoString(darkTrue),
			ANSI256:   C.GoString(darkAnsi256),
			ANSI:      C.GoString(darkAnsi),
		},
	})

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_background_complete_adaptive
func lipgloss_style_background_complete_adaptive(id C.ulonglong, lightTrue *C.char, lightAnsi256 *C.char, lightAnsi *C.char, darkTrue *C.char, darkAnsi256 *C.char, darkAnsi *C.char) C.ulonglong {
	style := getStyle(uint64(id)).Background(lipgloss.CompleteAdaptiveColor{
		Light: lipgloss.CompleteColor{
			TrueColor: C.GoString(lightTrue),
			ANSI256:   C.GoString(lightAnsi256),
			ANSI:      C.GoString(lightAnsi),
		},
		Dark: lipgloss.CompleteColor{
			TrueColor: C.GoString(darkTrue),
			ANSI256:   C.GoString(darkAnsi256),
			ANSI:      C.GoString(darkAnsi),
		},
	})

	return C.ulonglong(allocStyle(style))
}

// Size methods

//export lipgloss_style_width
func lipgloss_style_width(id C.ulonglong, width C.int) C.ulonglong {
	style := getStyle(uint64(id)).Width(int(width))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_height
func lipgloss_style_height(id C.ulonglong, height C.int) C.ulonglong {
	style := getStyle(uint64(id)).Height(int(height))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_max_width
func lipgloss_style_max_width(id C.ulonglong, width C.int) C.ulonglong {
	style := getStyle(uint64(id)).MaxWidth(int(width))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_max_height
func lipgloss_style_max_height(id C.ulonglong, height C.int) C.ulonglong {
	style := getStyle(uint64(id)).MaxHeight(int(height))
	return C.ulonglong(allocStyle(style))
}

// Alignment methods

//export lipgloss_style_align
func lipgloss_style_align(id C.ulonglong, positions *C.double, count C.int) C.ulonglong {
	goPositions := make([]lipgloss.Position, int(count))
	slice := unsafe.Slice(positions, int(count))

	for index, value := range slice {
		goPositions[index] = lipgloss.Position(value)
	}

	style := getStyle(uint64(id)).Align(goPositions...)

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_align_horizontal
func lipgloss_style_align_horizontal(id C.ulonglong, position C.double) C.ulonglong {
	style := getStyle(uint64(id)).AlignHorizontal(lipgloss.Position(position))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_align_vertical
func lipgloss_style_align_vertical(id C.ulonglong, position C.double) C.ulonglong {
	style := getStyle(uint64(id)).AlignVertical(lipgloss.Position(position))
	return C.ulonglong(allocStyle(style))
}

// Other style methods

//export lipgloss_style_inline
func lipgloss_style_inline(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).Inline(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_tab_width
func lipgloss_style_tab_width(id C.ulonglong, width C.int) C.ulonglong {
	style := getStyle(uint64(id)).TabWidth(int(width))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_underline_spaces
func lipgloss_style_underline_spaces(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).UnderlineSpaces(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_strikethrough_spaces
func lipgloss_style_strikethrough_spaces(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).StrikethroughSpaces(value != 0)
	return C.ulonglong(allocStyle(style))
}

// SetString and Inherit

//export lipgloss_style_set_string
func lipgloss_style_set_string(id C.ulonglong, text *C.char) C.ulonglong {
	style := getStyle(uint64(id)).SetString(C.GoString(text))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_inherit
func lipgloss_style_inherit(id C.ulonglong, inheritFromID C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).Inherit(getStyle(uint64(inheritFromID)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_string
func lipgloss_style_string(id C.ulonglong) *C.char {
	style := getStyle(uint64(id))
	return C.CString(style.String())
}
