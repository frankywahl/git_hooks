#!/usr/bin/env ruby

require_relative "../bash_colors"

require "optparse"

OptionParser.new do |opts|
  opts.on("--about") do
    puts "Makes sure code does not contain linting errors"
    exit
  end
end.parse!

class PreCommitHandler
  class Python
    attr_reader :files_changed
    def initialize
      @files_changed = `git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD`.strip.split("\n")
    end

    def handle
      if python_files_changed?
        exit(run_black)
      end
      exit(true)
    end


    private

    def run_black
      puts "Running Black code linter"
      system("black --check .", out: $stdout, err: :out)
    end

    def python_files_changed?
      files_changed.any?{ |file| file.match(/\.py$/) }
    end
  end
end

PreCommitHandler::Python.new.handle
