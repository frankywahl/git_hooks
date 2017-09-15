#!/usr/bin/env ruby

require_relative "../bash_colors"

require "optparse"

OptionParser.new do |opts|
  opts.on("--about") do
    puts "Runs yarn to get latest yarn packages"
    exit
  end
end.parse!

module PostMergeHandler
  class JavaScript
    attr_reader :files_changed
    def initialize
      @files_changed = `git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD`.strip.split("\n")
    end

    def handle
      run_yarn if yarn_changed?
    end

    private

    def yarn_changed?
      files_changed.include? "yarn.lock"
    end

    def run_yarn
      puts "Running yarn..."
      system("yarn install --pure-lockfile", out: $stdout, err: :out)
    end
  end
end

PostMergeHandler::JavaScript.new.handle
