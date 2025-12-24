package main

import "C"

import (
	"encoding/json"
	"github.com/lucasb-eyer/go-colorful"
)

//export lipgloss_color_blend_luv
func lipgloss_color_blend_luv(c1 *C.char, c2 *C.char, t C.double) *C.char {
	color1, err := colorful.Hex(C.GoString(c1))
	if err != nil {
		return C.CString(C.GoString(c1))
	}

	color2, err := colorful.Hex(C.GoString(c2))
	if err != nil {
		return C.CString(C.GoString(c1))
	}

	blended := color1.BlendLuv(color2, float64(t))
	return C.CString(blended.Hex())
}

//export lipgloss_color_blend_rgb
func lipgloss_color_blend_rgb(c1 *C.char, c2 *C.char, t C.double) *C.char {
	color1, err := colorful.Hex(C.GoString(c1))
	if err != nil {
		return C.CString(C.GoString(c1))
	}

	color2, err := colorful.Hex(C.GoString(c2))
	if err != nil {
		return C.CString(C.GoString(c1))
	}

	blended := color1.BlendRgb(color2, float64(t))
	return C.CString(blended.Hex())
}

//export lipgloss_color_blend_hcl
func lipgloss_color_blend_hcl(c1 *C.char, c2 *C.char, t C.double) *C.char {
	color1, err := colorful.Hex(C.GoString(c1))
	if err != nil {
		return C.CString(C.GoString(c1))
	}

	color2, err := colorful.Hex(C.GoString(c2))
	if err != nil {
		return C.CString(C.GoString(c1))
	}

	blended := color1.BlendHcl(color2, float64(t))
	return C.CString(blended.Hex())
}

//export lipgloss_color_blends
func lipgloss_color_blends(c1 *C.char, c2 *C.char, steps C.int, blendMode C.int) *C.char {
	color1, err := colorful.Hex(C.GoString(c1))
	if err != nil {
		return C.CString("[]")
	}

	color2, err := colorful.Hex(C.GoString(c2))
	if err != nil {
		return C.CString("[]")
	}

	n := int(steps)
	colors := make([]string, n)

	for i := 0; i < n; i++ {
		t := float64(i) / float64(n-1)
		if n == 1 {
			t = 0
		}

		var blended colorful.Color
		switch int(blendMode) {
		case 0: // LUV
			blended = color1.BlendLuv(color2, t)
		case 1: // RGB
			blended = color1.BlendRgb(color2, t)
		case 2: // HCL
			blended = color1.BlendHcl(color2, t)
		default:
			blended = color1.BlendLuv(color2, t)
		}
		colors[i] = blended.Hex()
	}

	result, _ := json.Marshal(colors)
	return C.CString(string(result))
}

//export lipgloss_color_grid
func lipgloss_color_grid(x0y0 *C.char, x1y0 *C.char, x0y1 *C.char, x1y1 *C.char, xSteps C.int, ySteps C.int, blendMode C.int) *C.char {
	c00, err := colorful.Hex(C.GoString(x0y0))
	if err != nil {
		return C.CString("[]")
	}

	c10, err := colorful.Hex(C.GoString(x1y0))
	if err != nil {
		return C.CString("[]")
	}

	c01, err := colorful.Hex(C.GoString(x0y1))
	if err != nil {
		return C.CString("[]")
	}

	c11, err := colorful.Hex(C.GoString(x1y1))
	if err != nil {
		return C.CString("[]")
	}

	nx := int(xSteps)
	ny := int(ySteps)
	mode := int(blendMode)

	blendFunc := func(a, b colorful.Color, t float64) colorful.Color {
		switch mode {
		case 0: // LUV
			return a.BlendLuv(b, t)
		case 1: // RGB
			return a.BlendRgb(b, t)
		case 2: // HCL
			return a.BlendHcl(b, t)
		default:
			return a.BlendLuv(b, t)
		}
	}

	x0 := make([]colorful.Color, ny)
	x1 := make([]colorful.Color, ny)

	for y := 0; y < ny; y++ {
		t := float64(y) / float64(ny)

		if ny == 1 {
			t = 0
		}

		x0[y] = blendFunc(c00, c01, t)
		x1[y] = blendFunc(c10, c11, t)
	}

	grid := make([][]string, ny)

	for y := 0; y < ny; y++ {
		grid[y] = make([]string, nx)

		for x := 0; x < nx; x++ {
			t := float64(x) / float64(nx)

			if nx == 1 {
				t = 0
			}

			grid[y][x] = blendFunc(x0[y], x1[y], t).Hex()
		}
	}

	result, _ := json.Marshal(grid)
	return C.CString(string(result))
}
