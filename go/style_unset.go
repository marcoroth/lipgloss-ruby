package main

import "C"

//export lipgloss_style_unset_bold
func lipgloss_style_unset_bold(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetBold()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_italic
func lipgloss_style_unset_italic(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetItalic()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_underline
func lipgloss_style_unset_underline(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetUnderline()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_strikethrough
func lipgloss_style_unset_strikethrough(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetStrikethrough()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_reverse
func lipgloss_style_unset_reverse(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetReverse()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_blink
func lipgloss_style_unset_blink(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetBlink()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_faint
func lipgloss_style_unset_faint(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetFaint()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_foreground
func lipgloss_style_unset_foreground(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetForeground()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_background
func lipgloss_style_unset_background(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetBackground()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_width
func lipgloss_style_unset_width(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetWidth()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_height
func lipgloss_style_unset_height(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetHeight()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_padding_top
func lipgloss_style_unset_padding_top(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetPaddingTop()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_padding_right
func lipgloss_style_unset_padding_right(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetPaddingRight()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_padding_bottom
func lipgloss_style_unset_padding_bottom(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetPaddingBottom()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_padding_left
func lipgloss_style_unset_padding_left(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetPaddingLeft()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_margin_top
func lipgloss_style_unset_margin_top(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetMarginTop()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_margin_right
func lipgloss_style_unset_margin_right(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetMarginRight()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_margin_bottom
func lipgloss_style_unset_margin_bottom(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetMarginBottom()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_margin_left
func lipgloss_style_unset_margin_left(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetMarginLeft()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_border_style
func lipgloss_style_unset_border_style(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetBorderStyle()
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_unset_inline
func lipgloss_style_unset_inline(id C.ulonglong) C.ulonglong {
	style := getStyle(uint64(id)).UnsetInline()
	return C.ulonglong(allocStyle(style))
}
