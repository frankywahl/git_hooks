require 'rspec'
require 'pry'
require 'pry-stack_explorer'
require_relative '../bash_colors'

# Ignore option parser
class OptionParser
  undef :parse!
  def parse!
  end
end

class IO
  alias_method :_puts, :puts
  undef :puts
  def puts(*argc)
  end
end

%w(
  ../pre-commit/debugger_checker
  ../pre-push/prevent_master_force
  ../post-merge/rails_after_hook
).each do |f|
  begin
    require_relative f
  rescue SystemExit
  end
end

class IO
  undef :puts
  alias_method :puts, :_puts
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

RSpec.configure do |c|
  c.color = true
  c.formatter = :documentation
end
