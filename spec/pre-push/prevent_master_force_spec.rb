require 'spec_helper'

describe PrePushHandler do
  let(:handler) { self.described_class.new }
  let(:message) { <<-EOF.strip_heredoc
      ****************************************
      Your attempt to \e[31mFORCE PUSH to MASTER\e[39m has been rejected.
      If you still want to FORCE PUSH then you need to ignore the pre_push git hook by executing following command.
      git push master --force --no-verify
      ****************************************
  EOF
  }

  context "current branch is master" do

    before :each do
      allow_any_instance_of(Object).to receive(:`).with("git branch").and_return("* master\nfoo")
    end

    context "force pushing current branch" do

      it "fails" do
        allow_any_instance_of(Object).to receive(:`).with("ps -ocommand").and_return("git push -f")
        expect(STDOUT).to receive(:puts).once
        expect {handler.handle}.to raise_error SystemExit
      end

    end

    context "force pushing to a different branch" do

      it "will not fail" do
        allow_any_instance_of(Object).to receive(:`).with("ps -ocommand").and_return("git push remote my_branch -f")
        expect(STDOUT).to receive(:puts).never
        expect {handler.handle}.not_to raise_error
      end

    end

  end

  context "current branch is not master" do

    before :each do
      allow_any_instance_of(Object).to receive(:`).with("git branch").and_return("master\n* foo")
    end

    context "force pushing current branch" do

      it "will not fail" do
        allow_any_instance_of(Object).to receive(:`).with("ps -ocommand").and_return("git push -f")
        expect(STDOUT).to receive(:puts).never
        expect {handler.handle}.not_to raise_error
      end

    end

    context "force pushing a different branch" do

      it "will not fail" do
        allow_any_instance_of(Object).to receive(:`).with("ps -ocommand").and_return("git push remote my_branch -f")
        expect(STDOUT).to receive(:puts).never
        expect {handler.handle}.not_to raise_error
      end

    end

    context "force pushing the master branch" do

      it "fails" do
        allow_any_instance_of(Object).to receive(:`).with("ps -ocommand").and_return("git push origin master -f")
        expect(STDOUT).to receive(:puts).once
        expect {handler.handle}.to raise_error SystemExit
      end

    end

    context "pushing to a different branch" do

      it "will not fail" do
        allow_any_instance_of(Object).to receive(:`).with("ps -ocommand").and_return("git push origin master:foo -f")
        expect(STDOUT).to receive(:puts).never
        expect {handler.handle}.not_to raise_error
      end

    end

    context "pushing a different branch to master" do

      it "fails" do
        allow_any_instance_of(Object).to receive(:`).with("ps -ocommand").and_return("git push origin foo:master -f")
        expect(STDOUT).to receive(:puts).once
        expect {handler.handle}.to raise_error SystemExit
      end

    end

  end

end
