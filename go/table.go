package main

import "C"

import (
	"encoding/json"
	"fmt"
	"github.com/charmbracelet/lipgloss"
	lipglosstable "github.com/charmbracelet/lipgloss/table"
)

func allocTable(table *lipglosstable.Table) uint64 {
	tablesMu.Lock()
	defer tablesMu.Unlock()
	id := getNextID()
	tables[id] = table

	return id
}

func getTable(id uint64) *lipglosstable.Table {
	tablesMu.RLock()
	defer tablesMu.RUnlock()

	return tables[id]
}

//export lipgloss_table_new
func lipgloss_table_new() C.ulonglong {
	return C.ulonglong(allocTable(lipglosstable.New()))
}

//export lipgloss_table_free
func lipgloss_table_free(id C.ulonglong) {
	tablesMu.Lock()
	defer tablesMu.Unlock()
	delete(tables, uint64(id))
}

//export lipgloss_table_headers
func lipgloss_table_headers(id C.ulonglong, headersJSON *C.char) C.ulonglong {
	var headers []string

	if err := json.Unmarshal([]byte(C.GoString(headersJSON)), &headers); err != nil {
		return id
	}

	table := getTable(uint64(id)).Headers(headers...)

	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_row
func lipgloss_table_row(id C.ulonglong, rowJSON *C.char) C.ulonglong {
	var row []string

	if err := json.Unmarshal([]byte(C.GoString(rowJSON)), &row); err != nil {
		return id
	}

	table := getTable(uint64(id)).Row(row...)

	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_rows
func lipgloss_table_rows(id C.ulonglong, rowsJSON *C.char) C.ulonglong {
	var rows [][]string

	if err := json.Unmarshal([]byte(C.GoString(rowsJSON)), &rows); err != nil {
		return id
	}

	table := getTable(uint64(id)).Rows(rows...)

	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border
func lipgloss_table_border(id C.ulonglong, borderType C.int) C.ulonglong {
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
	case 9:
		border = lipgloss.MarkdownBorder()
	default:
		border = lipgloss.NormalBorder()
	}

	table := getTable(uint64(id)).Border(border)

	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_style
func lipgloss_table_border_style(id C.ulonglong, styleID C.ulonglong) C.ulonglong {
	style := getStyle(uint64(styleID))
	table := getTable(uint64(id)).BorderStyle(style)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_top
func lipgloss_table_border_top(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).BorderTop(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_bottom
func lipgloss_table_border_bottom(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).BorderBottom(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_left
func lipgloss_table_border_left(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).BorderLeft(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_right
func lipgloss_table_border_right(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).BorderRight(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_header
func lipgloss_table_border_header(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).BorderHeader(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_column
func lipgloss_table_border_column(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).BorderColumn(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_border_row
func lipgloss_table_border_row(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).BorderRow(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_width
func lipgloss_table_width(id C.ulonglong, width C.int) C.ulonglong {
	table := getTable(uint64(id)).Width(int(width))
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_height
func lipgloss_table_height(id C.ulonglong, height C.int) C.ulonglong {
	table := getTable(uint64(id)).Height(int(height))
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_offset
func lipgloss_table_offset(id C.ulonglong, offset C.int) C.ulonglong {
	table := getTable(uint64(id)).Offset(int(offset))
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_wrap
func lipgloss_table_wrap(id C.ulonglong, value C.int) C.ulonglong {
	table := getTable(uint64(id)).Wrap(value != 0)
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_clear_rows
func lipgloss_table_clear_rows(id C.ulonglong) C.ulonglong {
	table := getTable(uint64(id)).ClearRows()
	return C.ulonglong(allocTable(table))
}

//export lipgloss_table_render
func lipgloss_table_render(id C.ulonglong) *C.char {
	table := getTable(uint64(id))
	return C.CString(table.Render())
}

//export lipgloss_table_style_func
func lipgloss_table_style_func(id C.ulonglong, styleMapJSON *C.char) C.ulonglong {
	var styleMap map[string]uint64

	if err := json.Unmarshal([]byte(C.GoString(styleMapJSON)), &styleMap); err != nil {
		return id
	}

	styleFunc := func(row, column int) lipgloss.Style {
		key := fmt.Sprintf("%d,%d", row, column)

		if styleID, ok := styleMap[key]; ok {
			return getStyle(styleID)
		}

		return lipgloss.NewStyle()
	}

	table := getTable(uint64(id)).StyleFunc(styleFunc)
	return C.ulonglong(allocTable(table))
}
