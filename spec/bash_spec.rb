require 'spec_helper'

describe Bash do
  describe "text" do
    it "#red" do
      expect(self.described_class::Text.red{"hello"}).to eql("\e[31mhello\e[39m")
    end

    it "#white" do
      expect(self.described_class::Text.white{"hello"}).to eql("\e[97mhello\e[39m")
    end
  end

  describe "background" do
    it "#red" do
      expect(self.described_class::Background.red{"hello"}).to eql("\e[41mhello\e[49m")
    end
    it "#white" do
      expect(self.described_class::Background.white{"hello"}).to eql("\e[107mhello\e[49m")
    end
  end

  describe "formatting" do
    it "#bold" do
      expect(self.described_class::Formatting.bold{"hello"}).to eql("\e[1mhello\e[21m")
    end
    it "#dim" do
      expect(self.described_class::Formatting.dim{"hello"}).to eql("\e[2mhello\e[22m")
    end
  end

end
