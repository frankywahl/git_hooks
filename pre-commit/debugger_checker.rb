#!/usr/bin/env ruby

require_relative "../bash_colors"

require "optparse"

OptionParser.new do |opts|
  opts.on("--about") do
    puts "Makes sure code does not contain any breaking point"
  end
end.parse!

class PreCommitHandler
  attr_accessor :file_errors

  def initialize
    @file_errors = []
  end

  def handle
    reject if code_contains_breakpoints?
  end

  private

  def code_contains_breakpoints?
    commiting_files.each do |file|
      analyzer = FileAnalyzer.new(file)
      file_errors << analyzer.errors if analyzer.contains_breakpoints?
    end
    file_errors.count > 0
  end

  def commiting_files
    `git diff --name-only --cached`.chomp.split("\n")
  end

  def reject
    messages = ["Your attempt to COMMIT was rejected"]
    messages << nil
    messages << file_errors
    messages << nil
    messages << "If you still want to commit then you need to ignore the pre_commit git hook by executing following command."
    messages << "git commit --no-verify OR git commit -n"
    feedback messages
  end

  def feedback(messages)
    stars = "*" * 40
    puts [stars, messages, stars].flatten.join("\n")
    exit 1
  end

  class FileAnalyzer
    attr_reader :file, :extension
    attr_accessor :errors

    def initialize(file)
      @file = file
      @extension = file.split(".").last
      @errors = []
    end

    def contains_breakpoints?
      return false if skip_file?
      text = `git show :#{file}`
      file_type.breakpoints.each do |breakpoint|
        if text.scan(/#{breakpoint}/).count > 0
          errors << "File #{Bash::Text.red { "./#{file}" }} contains #{breakpoint}"
        end
      end
      errors.count > 0
    end

    private

    def file_type
      @file_type ||= FileType.for(extension)
    end

    def skip_file?
      extension.nil? || file_type.nil? || !(File.file? file)
    end
  end

  class FileType
    DATASTORE = {}
    def self.register(extension:, breakpoints:)
      DATASTORE[extension] = FileType.new(extension: extension, breakpoints: breakpoints)
    end

    def self.for(extension)
      DATASTORE[extension]
    end

    def initialize(extension:, breakpoints:)
      @extension = extension
      @breakpoints = breakpoints
    end
  end
end
PreCommitHandler::FileType.register(extension: :rb, breakpoints: ["binding.pry", "debugger"])
PreCommitHandler.new.handle
