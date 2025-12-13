package main

import "C"

import (
	"unsafe"

	"github.com/charmbracelet/lipgloss"
)

//export lipgloss_style_border
func lipgloss_style_border(id C.ulonglong, borderType C.int, sides *C.int, sidesCount C.int) C.ulonglong {
	var border lipgloss.Border

	switch int(borderType) {
	case 0:
		border = lipgloss.NormalBorder()
	case 1:
		border = lipgloss.RoundedBorder()
	case 2:
		border = lipgloss.ThickBorder()
	case 3:
		border = lipgloss.DoubleBorder()
	case 4:
		border = lipgloss.HiddenBorder()
	case 5:
		border = lipgloss.BlockBorder()
	case 6:
		border = lipgloss.OuterHalfBlockBorder()
	case 7:
		border = lipgloss.InnerHalfBlockBorder()
	case 8:
		border = lipgloss.ASCIIBorder()
	default:
		border = lipgloss.NormalBorder()
	}

	if sidesCount > 0 {
		goSides := make([]bool, int(sidesCount))
		slice := unsafe.Slice(sides, int(sidesCount))

		for index, value := range slice {
			goSides[index] = value != 0
		}

		style := getStyle(uint64(id)).Border(border, goSides...)

		return C.ulonglong(allocStyle(style))
	}

	style := getStyle(uint64(id)).Border(border)

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_style
func lipgloss_style_border_style(id C.ulonglong, borderType C.int) C.ulonglong {
	var border lipgloss.Border

	switch int(borderType) {
	case 0:
		border = lipgloss.NormalBorder()
	case 1:
		border = lipgloss.RoundedBorder()
	case 2:
		border = lipgloss.ThickBorder()
	case 3:
		border = lipgloss.DoubleBorder()
	case 4:
		border = lipgloss.HiddenBorder()
	case 5:
		border = lipgloss.BlockBorder()
	case 6:
		border = lipgloss.OuterHalfBlockBorder()
	case 7:
		border = lipgloss.InnerHalfBlockBorder()
	case 8:
		border = lipgloss.ASCIIBorder()
	default:
		border = lipgloss.NormalBorder()
	}

	style := getStyle(uint64(id)).BorderStyle(border)

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_custom
func lipgloss_style_border_custom(id C.ulonglong, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight, middleLeft, middleRight, middle, middleTop, middleBottom *C.char) C.ulonglong {
	border := lipgloss.Border{
		Top:          C.GoString(top),
		Bottom:       C.GoString(bottom),
		Left:         C.GoString(left),
		Right:        C.GoString(right),
		TopLeft:      C.GoString(topLeft),
		TopRight:     C.GoString(topRight),
		BottomLeft:   C.GoString(bottomLeft),
		BottomRight:  C.GoString(bottomRight),
		MiddleLeft:   C.GoString(middleLeft),
		MiddleRight:  C.GoString(middleRight),
		Middle:       C.GoString(middle),
		MiddleTop:    C.GoString(middleTop),
		MiddleBottom: C.GoString(middleBottom),
	}

	style := getStyle(uint64(id)).Border(border)

	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_foreground
func lipgloss_style_border_foreground(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderForeground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_background
func lipgloss_style_border_background(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderBackground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_top
func lipgloss_style_border_top(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).BorderTop(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_right
func lipgloss_style_border_right(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).BorderRight(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_bottom
func lipgloss_style_border_bottom(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).BorderBottom(value != 0)
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_left
func lipgloss_style_border_left(id C.ulonglong, value C.int) C.ulonglong {
	style := getStyle(uint64(id)).BorderLeft(value != 0)
	return C.ulonglong(allocStyle(style))
}

// Per-side border foreground colors

//export lipgloss_style_border_top_foreground
func lipgloss_style_border_top_foreground(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderTopForeground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_right_foreground
func lipgloss_style_border_right_foreground(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderRightForeground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_bottom_foreground
func lipgloss_style_border_bottom_foreground(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderBottomForeground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_left_foreground
func lipgloss_style_border_left_foreground(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderLeftForeground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

// Per-side border background colors

//export lipgloss_style_border_top_background
func lipgloss_style_border_top_background(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderTopBackground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_right_background
func lipgloss_style_border_right_background(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderRightBackground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_bottom_background
func lipgloss_style_border_bottom_background(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderBottomBackground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}

//export lipgloss_style_border_left_background
func lipgloss_style_border_left_background(id C.ulonglong, color *C.char) C.ulonglong {
	style := getStyle(uint64(id)).BorderLeftBackground(lipgloss.Color(C.GoString(color)))
	return C.ulonglong(allocStyle(style))
}
