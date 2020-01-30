package main

import (
	"flag"
	"fmt"
	"log"
	"strings"

	"github.com/frankywahl/git_hooks"
)

func main() {
	var about bool
	flag.BoolVar(&about, "about", false, "know about this command")
	flag.Parse()

	if about {
		fmt.Println("Runs migrations and bundle if need be")
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
		if file == "Gemfile.lock" {
			fmt.Println("Running bundle…")
			if err := git_hooks.Run("bundle", "install"); err != nil {
				return fmt.Errorf("faild to run bundle")
			}
		}

	}

	anyMigrations := func(files []string) bool {
		for _, file := range files {
			if strings.Contains(file, "db/migrate") {
				return true
			}
		}
		return false
	}

	if anyMigrations(files) {
		fmt.Println("Running migrations…")
		if err := git_hooks.Run("bundle", "exec", "rake", "db:migrate", "db:test:prepare"); err != nil {
			return fmt.Errorf("faild to run migrations")
		}
	}

	return nil
}
