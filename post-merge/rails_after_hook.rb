#!/usr/bin/env ruby

require_relative "../bash_colors"

require "optparse"

OptionParser.new do |opts|
  opts.on("--about") do
    puts "Runs migrations and bundle if need be"
    exit
  end
end.parse!

module PostMergeHandler
  class Ruby
    attr_reader :files_changed
    def initialize
      @files_changed = `git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD`.strip.split("\n")
    end

    def handle
      run_bundle if gemfile_changed?
      run_rake if pending_migrations?
    end

    private

    def gemfile_changed?
      files_changed.include? "Gemfile.lock"
    end

    def pending_migrations?
      files_changed.each do |file|
        return true if file =~ /^db\/migrate\/.*\.rb/
      end
      false
    end

    def run_bundle
      puts "Running bundle..."
      system("bundle install", out: $stdout, err: :out)
    end

    def run_rake
      puts "Running migrations..."
      system("bundle exec rake db:migrate db:seed", out: $stdout, err: :out)
    end
  end
end

PostMergeHandler::Ruby.new.handle
