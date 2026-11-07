package main

import (
	"testing"
)

type TooltipDetailTestCase struct {
	detail   TooltipDetail
	expected string
}

func TestCreate(t *testing.T) {
	actual := TooltipDetail{}
	actual.heading("Wednesday")
	actual.add_entry("Presentation")
	actual.add_entry("Open bank account")
	actual.add_entry("Anniversary dinner")

	if al := len(actual.Entries); al != 3 {
		t.Errorf(`TestCreate TooltipDetail should have 3 entries, not %d, error`, al)
	}

}

func TestStringify(t *testing.T) {
	testcases := []TooltipDetailTestCase{
		{
			detail: TooltipDetail{
				Heading: "Today",
				Entries: []string{
					"Some line", "another line",
				},
			},
			expected: "<b>Today</b>\nSome line\nanother line\n",
		},
		{ /* test case for escaping ampersands */
			detail: TooltipDetail{
				Heading: "Tomorrow",
				Entries: []string{
					"Mills & Boon bookclub & barbecue",
				},
			},
			expected: "<b>Tomorrow</b>\nMills &amp; Boon bookclub &amp; barbecue\n",
		},
	}

	for n, testcase := range testcases {
		if actual := testcase.detail.stringify(); actual != testcase.expected {
			t.Errorf(`TestStringify #%d = %q, want %q, error`, n, actual, testcase.expected)
		}
	}
}
