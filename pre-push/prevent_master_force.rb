#!/usr/bin/env ruby

require_relative "../bash_colors"

# Read this blog to know more about this script.
#
# http://blog.bigbinary.com/2013/09/19/do-not-allow-force-pusht-to-master.html

require "optparse"

OptionParser.new do |opts|
  opts.on("--about") do
    puts "Prevents force pushing to master"
  end
end.parse!

class PrePushHandler
  def handle
    reject if pushing_to_master? && forced_push?
  end

  private

  def pushing_to_master?
    return true if push_cmd =~ /master /
    current_branch == "master" && !indicating_different_branch?
  end

  def current_branch
    result = `git branch`.split("\n")
    if result.empty?
      feedback "It seems your app is not a git repository."
    else
      result.select { |b| b =~ /^\*/ }.first.split(" ").last.strip
    end
  end

  def reject
    messages = ["Your attempt to #{Bash::Text.red { 'FORCE PUSH to MASTER' }} has been rejected."]
    messages << "If you still want to FORCE PUSH then you need to ignore the pre_push git hook by executing following command."
    messages << "git push master --force --no-verify"
    feedback messages
  end

  def forced_push?
    push_cmd.match(/--force|-f/)
  end

  def feedback(messages)
    stars = "*" * 40
    puts [stars, messages, stars].flatten.join("\n")
    exit 1
  end

  def push_cmd
    @push_cmd ||= begin
      cmd = `ps -ocommand`.strip
      cmd.scan(/^git push.*/).first.to_s
    end
  end

  def options_count_to_low?
    push_cmd.split(" ").reject { |x| x.match(/-/) }.count < 3
  end

  def indicating_different_branch?
    return false if options_count_to_low?
    if string = push_cmd.scan(/(master):(\w+)/).flatten
      string[1] != "master"
    end
  end
end

PrePushHandler.new.handle
