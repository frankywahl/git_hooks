package main

import (
	"flag"
	"fmt"
	"html/template"
	"log"
	"os"
	"strings"

	"github.com/frankywahl/git_hooks"
	"github.com/gookit/color"
)

const tmplate string = `***********************************************************
Your attempt to COMMIT was rejected
{{ range $file := . }}
File {{ print_error $file.FileName }} contains {{ yellow $file.Breakpoint }}
{{- end }}

If you still want to commit then you need to ignore the pre_commit git hook by executing following command.
git commit --no-verify OR git commit -n
***********************************************************
`

type FileError struct {
	FileName   string
	Breakpoint string
}

type fileDesc struct {
	Breakpoints []string
	Comment     string
}

func main() {
	var about bool
	flag.BoolVar(&about, "about", false, "know about this command")
	flag.Parse()

	if about {
		fmt.Println("Makes sure code does not contain any breaking point")
		return
	}

	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	fileTypes := map[string]fileDesc{
		"rb": fileDesc{
			Breakpoints: []string{"binding.pry", "debugger"},
			Comment:     "#",
		},
		"js": fileDesc{
			Breakpoints: []string{},
			Comment:     "//",
		},
		"es6": fileDesc{
			Breakpoints: []string{},
			Comment:     "//",
		},
		"coffee": fileDesc{
			Breakpoints: []string{},
			Comment:     "#",
		},
		"go": fileDesc{
			Breakpoints: []string{"debugger"},
			Comment:     "//",
		},
	}
	committingFiles, err := git_hooks.GetStagedFiles()
	if err != nil {
		return fmt.Errorf("could not get changed files: %w", err)
	}
	fileErrors := []*FileError{}

	for _, file := range committingFiles {
		extension := strings.Split(file, ".")[len(strings.Split(file, "."))-1]
		fileDes, ok := fileTypes[extension]
		if !ok {
			continue
		}
		if exist, _ := fileExists(file); !exist {
			continue
		}

		output, err := git_hooks.Git("show", fmt.Sprintf(":%s", file))
		if err != nil {
			return fmt.Errorf("could now view file %s: %w", file, err)
		}

		for _, bp := range fileDes.Breakpoints {
			if strings.Contains(output, bp) {
				fileErrors = append(fileErrors, &FileError{
					FileName:   file,
					Breakpoint: bp,
				})
			}
		}
	}

	tmpl, err := template.New("anything").Funcs(template.FuncMap{
		"print_error": func(i interface{}) (string, error) {
			return color.Red.Sprintf("%s", i), nil
		},
		"yellow": func(i interface{}) (string, error) {
			return color.Yellow.Sprintf("%s", i), nil
		},
	}).Parse(tmplate)
	if err != nil {
		return fmt.Errorf("could not create temaplte: %w", err)
	}
	if len(fileErrors) > 0 {
		if err := tmpl.Execute(os.Stdout, fileErrors); err != nil {
			return fmt.Errorf("could not execute template: %w", err)
		}
		return fmt.Errorf("code contains breakpoints")
	}
	return nil
}

func fileExists(filename string) (bool, error) {
	info, err := os.Stat(filename)
	if err != nil {
		if !os.IsNotExist(err) {
			return false, fmt.Errorf("could not get stat for %s: %w", filename, err)
		}
		return false, nil
	}
	return !info.IsDir(), nil
}
