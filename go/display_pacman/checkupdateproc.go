package main

import (
	"fmt"
	"github.com/oletalk/code-scrapbook/waybarutil"
	"slices"
	"strconv"
	"strings"
)

const (
	PACKAGE_ICON      = "📦"
	MAX_LINES_TOOLTIP = 4
)

func createWaybarOutput(cuOut []string) waybarutil.WaybarOutput {
	var waybarOutput waybarutil.WaybarOutput
	var tooltipLines []string
	packages := 0
	highlight := false
	for _, output := range cuOut {
		lineForTooltip := output
		packageName, details, found := strings.Cut(output, " ")
		if found && slices.Contains(SpecialPackages(), packageName) {
			newStr := fmt.Sprintf("<b>%s</b> %s", packageName, details)
			lineForTooltip = newStr
			waybarOutput.Class = "updates-special"

			highlight = true
			// tooltipLines = append(lineForTooltip, tooltipLines...)
			tooltipLines = slices.Insert(tooltipLines, 0, lineForTooltip)
		} else {
			tooltipLines = append(tooltipLines, lineForTooltip)
		}
		if strings.TrimSpace(output) != "" {
			packages++
		}
	}
	if highlight {
		waybarOutput.Text = PACKAGE_ICON + " <b>" + strconv.Itoa(packages) + "</b>"
	} else {
		waybarOutput.Text = PACKAGE_ICON + " " + strconv.Itoa(packages)
	}
	// cut down tooltip lines
	if len(tooltipLines) > MAX_LINES_TOOLTIP {
		tooltipLines = tooltipLines[:MAX_LINES_TOOLTIP]
		tooltipLines = append(tooltipLines, " ... more ... ")
	}
	waybarOutput.SetTooltip(tooltipLines)
	return waybarOutput
}
