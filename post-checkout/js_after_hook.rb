#!/usr/bin/env ruby

require_relative "../bash_colors"

require "optparse"

OptionParser.new do |opts|
  opts.on("--about") do
    puts "Runs yarn & npm to current packages"
    exit
  end
end.parse!

module PostCheckoutHandler
  class JavaScript
    attr_reader :files_changed
    def initialize(args)
      prev_head, new_head, @flag = args
      @files_changed = `git diff-tree -r --name-only --no-commit-id #{prev_head} #{new_head}`.strip.split("\n")
    end

    def handle
      return unless branch_checkout?
      run_yarn if yarn_changed?
      run_npm if npm_changed?
    end

    private

    def yarn_changed?
      files_changed.include? "yarn.lock"
    end

    def run_yarn
      puts "Running yarn..."
      system("yarn install --pure-lockfile", out: $stdout, err: :out)
    end

    def npm_changed?
      files_changed.include? "package-lock.json"
    end

    def run_npm
      puts "Running npm..."
      system("npm install", out: $stdout, err: :out)
    end

    # Identifies the difference between checkout out a branch
    # And checkout out a file
    def branch_checkout?
      @flag == "1"
    end
  end
end

PostCheckoutHandler::JavaScript.new(ARGV).handle
