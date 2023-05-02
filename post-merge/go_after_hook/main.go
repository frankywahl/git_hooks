package main

import (
	"flag"
	"fmt"
	"log"

	"github.com/frankywahl/git_hooks"
)

func main() {
	var about bool
	flag.BoolVar(&about, "about", false, "know about this command")
	flag.Parse()

	if about {
		fmt.Println("Run mod tidy after go mod changes")
		return
	}

	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	prevHead, newHead := "ORIG_HEAD", "HEAD"

	files, err := git_hooks.GetDiffFiles(prevHead, newHead)
	if err != nil {
		return fmt.Errorf("could not get the files changed: %w", err)
	}

	for _, file := range files {
		if file == "go.sum" {
			fmt.Println("Running go mod tidy…")
			if err := git_hooks.Run("go", "mod", "tidy"); err != nil {
				return fmt.Errorf("faild to run go mod tidy")
			}
		}

	}

	return nil
}
