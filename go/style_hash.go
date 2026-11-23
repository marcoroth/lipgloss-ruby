package main

import "C"

import (
	"encoding/json"
	"image/color"

	"charm.land/lipgloss/v2"
)

func colorToValue(c color.Color) any {
	switch v := c.(type) {
	case adaptiveColor:
		return map[string]any{"light": v.Light, "dark": v.Dark}
	case completeColor:
		return completeColorToValue(v)
	case completeAdaptiveColor:
		return map[string]any{
			"light": completeColorToValue(v.Light),
			"dark":  completeColorToValue(v.Dark),
		}
	}

	if s := colorString(c); s != "" {
		return s
	}

	return nil
}

func completeColorToValue(c completeColor) map[string]any {
	return map[string]any{"true_color": c.TrueColor, "ansi256": c.ANSI256, "ansi": c.ANSI}
}

func borderToValue(b lipgloss.Border) map[string]any {
	return map[string]any{
		"top":           b.Top,
		"bottom":        b.Bottom,
		"left":          b.Left,
		"right":         b.Right,
		"top_left":      b.TopLeft,
		"top_right":     b.TopRight,
		"bottom_left":   b.BottomLeft,
		"bottom_right":  b.BottomRight,
		"middle_left":   b.MiddleLeft,
		"middle_right":  b.MiddleRight,
		"middle":        b.Middle,
		"middle_top":    b.MiddleTop,
		"middle_bottom": b.MiddleBottom,
	}
}

func setIf(h map[string]any, key string, value any) {
	switch v := value.(type) {
	case nil:
		return
	case bool:
		if !v {
			return
		}
	case int:
		if v == 0 {
			return
		}
	}
	h[key] = value
}

func styleToHash(s lipgloss.Style) map[string]any {
	h := map[string]any{}

	setIf(h, "bold", s.GetBold())
	setIf(h, "italic", s.GetItalic())
	setIf(h, "underline", s.GetUnderline())
	setIf(h, "strikethrough", s.GetStrikethrough())
	setIf(h, "reverse", s.GetReverse())
	setIf(h, "blink", s.GetBlink())
	setIf(h, "faint", s.GetFaint())
	setIf(h, "inline", s.GetInline())

	setIf(h, "foreground", colorToValue(s.GetForeground()))
	setIf(h, "background", colorToValue(s.GetBackground()))

	setIf(h, "width", s.GetWidth())
	setIf(h, "height", s.GetHeight())
	setIf(h, "max_width", s.GetMaxWidth())
	setIf(h, "max_height", s.GetMaxHeight())

	if horizontal := s.GetAlignHorizontal(); horizontal != lipgloss.Left {
		h["align_horizontal"] = float64(horizontal)
	}
	if vertical := s.GetAlignVertical(); vertical != lipgloss.Top {
		h["align_vertical"] = float64(vertical)
	}

	if t, r, b, l := s.GetPadding(); t+r+b+l > 0 {
		h["padding"] = []int{t, r, b, l}
	}
	if t, r, b, l := s.GetMargin(); t+r+b+l > 0 {
		h["margin"] = []int{t, r, b, l}
	}

	border, top, right, bottom, left := s.GetBorder()
	if top || right || bottom || left {
		h["border"] = borderToValue(border)
		h["border_sides"] = []bool{top, right, bottom, left}

		foregrounds := []any{
			colorToValue(s.GetBorderTopForeground()),
			colorToValue(s.GetBorderRightForeground()),
			colorToValue(s.GetBorderBottomForeground()),
			colorToValue(s.GetBorderLeftForeground()),
		}
		backgrounds := []any{
			colorToValue(s.GetBorderTopBackground()),
			colorToValue(s.GetBorderRightBackground()),
			colorToValue(s.GetBorderBottomBackground()),
			colorToValue(s.GetBorderLeftBackground()),
		}

		for _, c := range foregrounds {
			if c != nil {
				h["border_foreground"] = foregrounds
				break
			}
		}
		for _, c := range backgrounds {
			if c != nil {
				h["border_background"] = backgrounds
				break
			}
		}
	}

	return h
}

//export lipgloss_style_to_json
func lipgloss_style_to_json(id C.ulonglong) *C.char {
	data, err := json.Marshal(styleToHash(getStyle(uint64(id))))
	if err != nil {
		return C.CString("{}")
	}

	return C.CString(string(data))
}
