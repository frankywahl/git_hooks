package main

import (
	"reflect"
	"regexp"
	"testing"
)

func TestGetMatches(t *testing.T) {
	tests := []struct {
		pattern string
		match   string
		result  map[string]string
	}{
		{
			pattern: `:(?P<target>\w+)`,
			match:   "git push origin foo:master",
			result: map[string]string{
				"target": "master",
			},
		},
	}

	for _, tc := range tests {
		r := regexp.MustCompile(tc.pattern)
		res := getMatches(r, tc.match)
		if !reflect.DeepEqual(res, tc.result) {
			t.Fatalf("expected: %#v, got: %#v", tc.result, res)
		}
	}
}

func TestIsIndicatingDifferntBranch(t *testing.T) {
	tests := []struct {
		cmd     string
		outcome bool
	}{
		{
			cmd:     "git push",
			outcome: false,
		},
		{
			cmd:     "git push foo:bar",
			outcome: false,
		},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.cmd, func(t *testing.T) {
			t.Parallel()
			if tc.outcome != isIndicatingDifferentBranch(tc.cmd) {
				t.Fatalf("expected %s to show branch %t", tc.cmd, tc.outcome)
			}
		})
	}
}

func TestIsForcedPushed(t *testing.T) {
	tests := []struct {
		cmd     string
		outcome bool
	}{
		{
			cmd:     "git push",
			outcome: false,
		},
		{
			cmd:     "git push -f",
			outcome: true,
		},
		{
			cmd:     "git push --force",
			outcome: true,
		},
		{
			cmd:     "git push --fry",
			outcome: false,
		},
	}

	for _, tc := range tests {
		tc := tc // capture range variable
		t.Run(tc.cmd, func(t *testing.T) {
			t.Parallel()
			if tc.outcome != isForcedPushed(tc.cmd) {
				t.Fatalf("expected %s to show branch %t", tc.cmd, tc.outcome)
			}
		})
	}
}
