package main

import (
	"flag"
	"fmt"
	"html/template"
	"log"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"github.com/frankywahl/git_hooks"
	"github.com/gookit/color"
)

const tmplate string = `***********************************************************
Your attempt to {{ print_error "FORCE PUSH" }} has been rejected
If you still want to FORCE PUSH then you need to ignore the pre_push git hook by executing following command.
git push {{ .BranchName }} --force --no-verify
***********************************************************
`

func main() {
	var about bool
	flag.BoolVar(&about, "about", false, "know about this command")
	flag.Parse()

	if about {
		fmt.Println("Prevents force pushing to master or main")
		return
	}

	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	cmd, err := pushCmd()
	if err != nil {
		return fmt.Errorf("could not get the pushCmd: %w", err)
	}

	if (isPushingTo("master", cmd) || isPushingTo("main", cmd)) && isForcedPushed(cmd) {
		tmpl, err := template.New("anything").Funcs(
			template.FuncMap{
				"print_error": func(i interface{}) (string, error) {
					return color.Red.Sprintf("%s", i), nil
				},
			},
		).Parse(tmplate)
		if err != nil {
			return fmt.Errorf("could not create temaplte: %w", err)
		}
		branchName, err := currentBranchName()
		if err != nil {
			panic(err)
		}
		if err := tmpl.Execute(os.Stdout, struct {
			BranchName string
		}{
			BranchName: branchName,
		}); err != nil {
			return fmt.Errorf("could not execute template: %w", err)
		}

		return fmt.Errorf("force pushing to %s is disabled", branchName)
	}
	return nil
}

func isForcedPushed(cmd string) bool {
	return strings.Contains(cmd, "--force") || strings.Contains(cmd, " -f")
}

func isPushingTo(branchName string, cmd string) bool {
	if strings.Contains(cmd, branchName+" ") {
		return true
	}

	if isIndicatingDifferentBranch(branchName, cmd) {
		return false
	}

	currentBranch, err := currentBranchName()
	if err != nil {
		return false
	}

	return currentBranch == branchName
}

func isIndicatingDifferentBranch(branchName, cmd string) bool {
	args := strings.Split(cmd, " ")

	cmdOptions := []string{}
	for _, arg := range args {
		if strings.HasPrefix(arg, "-") {
			cmdOptions = append(cmdOptions, arg)
		}
	}

	if len(cmdOptions) < 3 {
		return false
	}

	r := regexp.MustCompile(`:(?P<target>\w+)`)
	matchMap := getMatches(r, cmd)

	k, ok := matchMap["target"]
	if !ok {
		return true
	}
	return k != branchName
}

func getMatches(r *regexp.Regexp, str string) map[string]string {
	result := map[string]string{}

	match := r.FindStringSubmatch(str)
	for i, name := range r.SubexpNames() {
		if i > 0 && i <= len(match) {
			result[name] = match[i]
		}

	}
	return result
}

func pushCmd() (string, error) {
	cmd := exec.Command("ps", "-ocommand")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("could not scan processes: %w", err)
	}

	for _, line := range strings.Split(string(output), "\n") {
		_ = line
		if strings.HasPrefix(line, "git push") {
			return line, nil
		}
	}

	return "", nil
}

func currentBranchName() (string, error) {

	output, err := git_hooks.Git("rev-parse", "--abbrev-ref", "HEAD")
	if err != nil {
		return "", fmt.Errorf("could not get branch: %w", err)
	}
	return output, nil
}
