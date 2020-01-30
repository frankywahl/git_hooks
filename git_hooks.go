package git_hooks

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// Git runs a git command and return the output
func Git(args ...string) (string, error) {
	cmd := exec.Command("git", args...)
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("could not run command: %s: %w", strings.Join(args, " "), err)
	}
	return strings.TrimSuffix(string(output), "\n"), nil
}

// Run just runs a command with std in and std out
func Run(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// GetDiffFiles returns a list of files that changed between the
// two different versions
func GetDiffFiles(prevHead string, newHead string) ([]string, error) {
	output, err := Git("diff-tree", "-r", "--name-only", "--no-commit-id", prevHead, newHead)
	if err != nil {
		return []string{}, fmt.Errorf("could not run diff-tree: %w", err)
	}
	return strings.Split(output, "\n"), nil
}

// GetStagedFiles returns a list of files staged for committing
func GetStagedFiles() ([]string, error) {
	output, err := Git("diff", "--name-only", "--cached")
	if err != nil {
		return []string{}, fmt.Errorf("could not run diff: %w", err)
	}
	return strings.Split(output, "\n"), nil
}
