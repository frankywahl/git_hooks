require "spec_helper"

require_relative "../../post-merge/yarn_after_hook"

describe PostMergeHandler::JavaScript do
  let(:handler) { described_class.new }

  describe "#initialize" do
    it "initializes properly" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("Foo\nBar")
      expect(handler.files_changed).to match_array(%w[Foo Bar])
    end
  end

  describe "yarn install" do
    it "is ran when yarn.lock is changed" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("yarn.lock\nBar")
      expect(handler).to receive(:system).with("yarn install", out: $stdout, err: :out)
      handler.handle
    end

    it "is not ran if yarn.lock is unchanged" do
      allow_any_instance_of(Object).to receive(:`).with("git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD").and_return("Foo\nBar")
      expect(handler).to receive(:system).never
      handler.handle
    end
  end
end
