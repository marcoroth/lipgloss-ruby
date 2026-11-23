package main

import (
	"bytes"
	"fmt"
	"image/color"
	"os"
	"strconv"
	"sync"

	"charm.land/lipgloss/v2"
	"github.com/charmbracelet/colorprofile"
	"github.com/charmbracelet/x/ansi"
)

// Lip Gloss v2 no longer has a global renderer: styles always render
// full-color sequences and adaptive colors are resolved by the caller. The Ruby
// API still exposes the v1 model (a global color profile, a global dark
// background flag and AdaptiveColor/CompleteColor types that resolve at render
// time), so this file keeps that state and resolves it the way v1 did.

var (
	profileMu sync.RWMutex
	profile   = colorprofile.Detect(os.Stdout, os.Environ())

	darkMu       sync.RWMutex
	darkDetected bool
	darkValue    bool
)

func currentProfile() colorprofile.Profile {
	profileMu.RLock()
	defer profileMu.RUnlock()

	return profile
}

func setProfile(p colorprofile.Profile) {
	profileMu.Lock()
	defer profileMu.Unlock()

	profile = p
}

// hasDarkBackground queries the terminal on first use, like v1 did. Querying at
// load time would put the terminal in raw mode and read from stdin as soon as
// the gem is required.
func hasDarkBackground() bool {
	darkMu.RLock()
	if darkDetected {
		defer darkMu.RUnlock()
		return darkValue
	}
	darkMu.RUnlock()

	darkMu.Lock()
	defer darkMu.Unlock()

	if !darkDetected {
		darkValue = os.Getenv("NO_COLOR") != "" || lipgloss.HasDarkBackground(os.Stdin, os.Stdout)
		darkDetected = true
	}

	return darkValue
}

func setHasDarkBackground(dark bool) {
	darkMu.Lock()
	defer darkMu.Unlock()

	darkValue = dark
	darkDetected = true
}

// downsample converts the full-color output of Lip Gloss v2 to the current
// color profile. The ascii profile strips all styling, matching v1.
func downsample(s string) string {
	p := currentProfile()

	if p == colorprofile.TrueColor {
		return s
	}

	if p <= colorprofile.ASCII {
		return ansi.Strip(s)
	}

	var buf bytes.Buffer
	w := &colorprofile.Writer{Forward: &buf, Profile: p}
	_, _ = w.WriteString(s)

	return buf.String()
}

// Ruby passes profiles as indexes into Lipgloss::COLOR_PROFILES, which follow
// the termenv order used by v1.
var rubyProfiles = []colorprofile.Profile{
	colorprofile.TrueColor,
	colorprofile.ANSI256,
	colorprofile.ANSI,
	colorprofile.ASCII,
}

func profileToRuby(p colorprofile.Profile) int {
	switch p {
	case colorprofile.TrueColor:
		return 0
	case colorprofile.ANSI256:
		return 1
	case colorprofile.ANSI:
		return 2
	default:
		return 3
	}
}

func profileFromRuby(i int) colorprofile.Profile {
	if i < 0 || i >= len(rubyProfiles) {
		return colorprofile.ASCII
	}

	return rubyProfiles[i]
}

// colorNames remembers how each color was spelled when it was set, so getters
// and to_h can hand back "#7aa2f7" or "212" instead of a reformatted value.
var (
	colorNames   = map[color.Color]string{}
	colorNamesMu sync.RWMutex
)

// parseColor turns a v1 color string into a v2 color. Empty strings are
// treated as "no color", as in v1.
func parseColor(s string) color.Color {
	if s == "" {
		return lipgloss.NoColor{}
	}

	c := lipgloss.Color(s)

	if _, ok := c.(lipgloss.NoColor); !ok {
		colorNamesMu.Lock()
		colorNames[c] = s
		colorNamesMu.Unlock()
	}

	return c
}

// colorString is the inverse of parseColor. It returns "" for no color.
func colorString(c color.Color) string {
	switch c.(type) {
	case nil, lipgloss.NoColor:
		return ""
	case adaptiveColor:
		return ""
	case completeColor, completeAdaptiveColor:
		return ""
	}

	colorNamesMu.RLock()
	name, ok := colorNames[c]
	colorNamesMu.RUnlock()

	if ok {
		return name
	}

	switch v := c.(type) {
	case ansi.BasicColor:
		return strconv.Itoa(int(v))
	case ansi.IndexedColor:
		return strconv.Itoa(int(v))
	}

	r, g, b, _ := c.RGBA()

	return fmt.Sprintf("#%02x%02x%02x", r>>8, g>>8, b>>8)
}

// adaptiveColor picks Light or Dark based on the terminal background at render
// time, like lipgloss.AdaptiveColor in v1.
type adaptiveColor struct {
	Light string
	Dark  string
}

func (c adaptiveColor) resolve() color.Color {
	if hasDarkBackground() {
		return parseColor(c.Dark)
	}

	return parseColor(c.Light)
}

func (c adaptiveColor) RGBA() (r, g, b, a uint32) {
	return c.resolve().RGBA()
}

// completeColor picks an exact value for the current color profile, like
// lipgloss.CompleteColor in v1.
type completeColor struct {
	TrueColor string
	ANSI256   string
	ANSI      string
}

func (c completeColor) resolve() color.Color {
	switch currentProfile() {
	case colorprofile.TrueColor:
		return parseColor(c.TrueColor)
	case colorprofile.ANSI256:
		return parseColor(c.ANSI256)
	case colorprofile.ANSI:
		return parseColor(c.ANSI)
	default:
		return lipgloss.NoColor{}
	}
}

func (c completeColor) RGBA() (r, g, b, a uint32) {
	return c.resolve().RGBA()
}

// completeAdaptiveColor combines completeColor with light/dark selection.
type completeAdaptiveColor struct {
	Light completeColor
	Dark  completeColor
}

func (c completeAdaptiveColor) RGBA() (r, g, b, a uint32) {
	if hasDarkBackground() {
		return c.Dark.RGBA()
	}

	return c.Light.RGBA()
}
