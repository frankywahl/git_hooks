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
		fmt.Println("Runs yarn & npm to current packages")
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
		if file == "yarn.lock" {
			fmt.Println("Running yarn…")
			if err := git_hooks.Run("yarn", "install", "--pure-lockfile"); err != nil {
				return fmt.Errorf("faild to run yarn")
			}
		}

		if file == "package-lock.json" {
			fmt.Println("Running npm…")
			if err := git_hooks.Run("npm", "install"); err != nil {
				return fmt.Errorf("faild to run npm")
			}
		}
	}

	return nil
}
