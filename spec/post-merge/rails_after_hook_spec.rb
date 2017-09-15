require "spec_helper"

require_relative "../../post-merge/rails_after_hook"

describe PostMergeHandler::Ruby do
  let(:handler) { described_class.new }

  describe "#initialize" do
    it "initializes properly" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("Foo\nBar")
      expect(handler.files_changed).to match_array(%w[Foo Bar])
    end
  end

  describe "bundle install" do
    it "is ran when Gemfile is changed" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("Gemfile.lock\nBar")
      expect(handler).to receive(:system).with("bundle install", out: $stdout, err: :out)
      handler.handle
    end
    it "is not ran if Gemfile is unchanged" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("Foo\nBar")
      expect(handler).to receive(:system).never
      handler.handle
    end
  end

  describe "rake install" do
    it "is ran when migration files are changed" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("db/migrate/add_accounts_2001.rb\nBar")
      expect(handler).to receive(:system).with("bundle exec rake db:migrate db:seed", out: $stdout, err: :out)
      handler.handle
    end

    it "is not ran if migration files are unchanged" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("Foo\nBar")
      expect(handler).to receive(:system).never
      handler.handle
    end
  end
end
