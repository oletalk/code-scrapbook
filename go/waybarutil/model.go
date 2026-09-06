/*
Contains a model and basic manipulation methods for Go to output to the Waybar.
*/
package waybarutil

import (
	"encoding/json"
	"strings"
)

type WaybarOutput struct {
	Text    string `json:"text"`
	Tooltip string `json:"tooltip"`
}

/* output a json string from the contents of the object */
func (w WaybarOutput) ToJson() (string, error) {

	var outStr strings.Builder
	enc := json.NewEncoder(&outStr)
	enc.SetEscapeHTML(false) // not printing out to web so we're fine
	eerr := enc.Encode(w)
	if eerr != nil {
		return "", eerr
	} else {
		return outStr.String(), nil
	}
}

/* assemble tooltip from an array of strings */
func (w *WaybarOutput) SetTooltip(tooltipLines []string) {
	w.Tooltip = strings.Join(tooltipLines[:], "\n")
}
