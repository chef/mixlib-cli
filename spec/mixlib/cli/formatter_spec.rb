
require "mixlib/cli/formatter"

describe Mixlib::CLI::Formatter do
  Formatter = Mixlib::CLI::Formatter
  context "combined_option_display_name" do
    it "converts --option with short -o to '-s/--option'" do
      expect(Formatter.combined_option_display_name("-o", "--option")).to eql "-o/--option"
    end

    it "converts --option with no short to '--option'" do
      expect(Formatter.combined_option_display_name(nil, "--option")).to eql "--option"
    end
    it "converts short -o with no long option to '-o'" do
      expect(Formatter.combined_option_display_name("-o", nil)).to eql"-o"
    end

    it "converts options the same way even with an argument present" do
      expect(Formatter.combined_option_display_name("-o arg1", "--option arg1")).to eql "-o/--option"
    end

    it "converts options to a blank string if neither short nor long are present" do
      expect(Formatter.combined_option_display_name(nil, nil)).to eql ""
    end
  end

  context "friendly_opt_list" do
    it "for a single item it quotes it and returns it as a string" do
      expect(Formatter.friendly_opt_list(%w{hello})).to eql "'hello'"
    end
    it "for two items returns ..." do
      expect(Formatter.friendly_opt_list(%w{hello world})).to eql "'hello' or 'world'"
    end
    it "for three items returns..." do
      expect(Formatter.friendly_opt_list(%w{hello green world})).to eql "'hello', 'green', or 'world'"
    end
    it "for more than three items creates a list in the same was as three items" do
      expect(Formatter.friendly_opt_list(%w{hello green world good morning})).to eql "'hello', 'green', 'world', 'good', or 'morning'"
    end

  end

end
