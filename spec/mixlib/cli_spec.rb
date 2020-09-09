#
# Author:: Adam Jacob (<adam@chef.io>)
# Copyright:: Copyright (c) 2008-2019, Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(__dir__, "..", "spec_helper"))

describe Mixlib::CLI do
  after(:each) do
    TestCLI.options = {}
    TestCLI.banner("Usage: #{$0} (options)")
  end

  describe "class method" do
    describe "option" do
      it "allows you to set a config option with a hash" do
        expect(TestCLI.option(:config_file, short: "-c CONFIG")).to eql({ short: "-c CONFIG" })
      end
    end

    describe "deprecated_option" do
      it "makes a deprecated option when you declare one" do
        TestCLI.deprecated_option(:option_d, short: "-d")
        expect(TestCLI.options[:option_d]).to include(deprecated: true)
      end
    end

    describe "options" do
      it "returns the current options hash" do
        TestCLI.option(:config_file, short: "-c CONFIG")
        expect(TestCLI.options).to eql({ config_file: { short: "-c CONFIG" } })
      end
      it "includes deprecated options and their generated descriptions" do
        TestCLI.option(:config_file, short: "-c CONFIG")
        TestCLI.deprecated_option(:blah, short: "-b BLAH")
        TestCLI.deprecated_option(:blah2, long: "--blah2 BLAH", replacement: :config_file)
        opts = TestCLI.options
        expect(opts[:config_file][:short]).to eql("-c CONFIG")
        expect(opts[:config_file].key?(:deprecated)).to eql(false)
        expect(opts[:blah][:description]).to eql("This flag is deprecated and will be removed in a future release.")
        expect(opts[:blah][:deprecated]).to eql(true)
        expect(opts[:blah2][:description]).to eql("This flag is deprecated. Use -c instead.")
        expect(opts[:blah2][:deprecated]).to eql(true)
      end
    end

    describe "options=" do
      it "allows you to set the full options with a single hash" do
        TestCLI.options = { config_file: { short: "-c CONFIG" } }
        expect(TestCLI.options).to eql({ config_file: { short: "-c CONFIG" } })
      end
    end

    describe "banner" do
      it "has a default value" do
        expect(TestCLI.banner).to match(/^Usage: (.+) \(options\)$/)
      end

      it "allows you to set the banner" do
        TestCLI.banner("Usage: foo")
        expect(TestCLI.banner).to eql("Usage: foo")
      end
    end
  end

  context "when configured with default single-config-hash behavior" do

    before(:each) do
      @cli = TestCLI.new
    end

    describe "initialize" do
      it "sets the banner to the class defined banner" do
        expect(@cli.banner).to eql(TestCLI.banner)
      end

      it "sets the options to the class defined options and deprecated options, with defaults" do
        TestCLI.option(:config_file, short: "-l FILE")
        TestCLI.deprecated_option(:option_file, short: "-o FILE", replacement: :config_file)
        cli = TestCLI.new
        expect(cli.options[:config_file]).to eql({
            short: "-l FILE",
            on: :on,
            boolean: false,
            required: false,
            proc: nil,
            show_options: false,
            exit: nil,
            in: nil,
        })

        expect(cli.options[:option_file]).to include(
          boolean: false,
          deprecated: true,
          description: "This flag is deprecated. Use -l instead.",
          exit: nil,
          in: nil,
          long: nil,
          keep: true,
          proc: nil,
          replacement: :config_file,
          required: false,
          short: "-o FILE",
          on: :tail,
          show_options: false
        )
        expect(cli.options[:option_file][:value_mapper].class).to eql(Proc)
      end

      it "sets the default config value for any options that include it" do
        TestCLI.option(:config_file, short: "-l LOG", default: :debug)
        @cli = TestCLI.new
        expect(@cli.config[:config_file]).to eql(:debug)
      end
    end

    describe "opt_parser" do

      it "sets the banner in opt_parse" do
        expect(@cli.opt_parser.banner).to eql(@cli.banner)
      end

      it "presents the arguments in the banner" do
        TestCLI.option(:config_file, short: "-l LOG")
        @cli = TestCLI.new
        expect(@cli.opt_parser.to_s).to match(/-l LOG/)
      end

      it "honors :on => :tail options in the banner" do
        TestCLI.option(:config_file, short: "-l LOG")
        TestCLI.option(:help, short: "-h", boolean: true, on: :tail)
        @cli = TestCLI.new
        expect(@cli.opt_parser.to_s.split("\n").last).to match(/-h/)
      end

      it "honors :on => :head options in the banner" do
        TestCLI.option(:config_file, short: "-l LOG")
        TestCLI.option(:help, short: "-h", boolean: true, on: :head)
        @cli = TestCLI.new
        expect(@cli.opt_parser.to_s.split("\n")[1]).to match(/-h/)
      end

      it "presents the arguments in alphabetical order in the banner" do
        TestCLI.option(:alpha, short: "-a ALPHA")
        TestCLI.option(:beta, short: "-b BETA")
        TestCLI.option(:zeta, short: "-z ZETA")
        @cli = TestCLI.new
        output_lines = @cli.opt_parser.to_s.split("\n")
        expect(output_lines[1]).to match(/-a ALPHA/)
        expect(output_lines[2]).to match(/-b BETA/)
        expect(output_lines[3]).to match(/-z ZETA/)
      end

    end

    describe "parse_options" do
      it "sets the corresponding config value for non-boolean arguments" do
        TestCLI.option(:config_file, short: "-c CONFIG")
        @cli = TestCLI.new
        @cli.parse_options([ "-c", "foo.rb" ])
        expect(@cli.config[:config_file]).to eql("foo.rb")
      end

      it "sets the corresponding config value according to a supplied proc" do
        TestCLI.option(:number,
          short: "-n NUMBER",
          proc: Proc.new { |config| config.to_i + 2 })
        @cli = TestCLI.new
        @cli.parse_options([ "-n", "2" ])
        expect(@cli.config[:number]).to eql(4)
      end

      it "passes the existing value to two-argument procs" do
        TestCLI.option(:number,
          short: "-n NUMBER",
          proc: Proc.new { |value, existing| existing ||= []; existing << value; existing })
        @cli = TestCLI.new
        @cli.parse_options([ "-n", "2", "-n", "3" ])
        expect(@cli.config[:number]).to eql(%w{2 3})
      end

      it "sets the corresponding config value to true for boolean arguments" do
        TestCLI.option(:i_am_boolean, short: "-i", boolean: true)
        @cli = TestCLI.new
        @cli.parse_options([ "-i" ])
        expect(@cli.config[:i_am_boolean]).to be true
      end

      it "sets the corresponding config value to false when a boolean is prefixed with --no" do
        TestCLI.option(:i_am_boolean, long: "--[no-]bool", boolean: true)
        @cli = TestCLI.new
        @cli.parse_options([ "--no-bool" ])
        expect(@cli.config[:i_am_boolean]).to be false
      end

      it "exits if a config option has :exit set" do
        TestCLI.option(:i_am_exit, short: "-x", boolean: true, exit: 0)
        @cli = TestCLI.new
        expect(lambda { @cli.parse_options(["-x"]) }).to raise_error(SystemExit)
      end

      it "exits if a required option is missing" do
        TestCLI.option(:require_me, short: "-r", boolean: true, required: true)
        @cli = TestCLI.new
        expect(lambda { @cli.parse_options([]) }).to raise_error(SystemExit)
      end

      it "exits if option is not included in the list and required" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two}, required: true)
        @cli = TestCLI.new
        expect(lambda { @cli.parse_options(["-i", "three"]) }).to raise_error(SystemExit)
      end

      it "exits if option is not included in the list and not required" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two}, required: false)
        @cli = TestCLI.new
        expect(lambda { @cli.parse_options(["-i", "three"]) }).to raise_error(SystemExit)
      end

      it "doesn't exit if option is nil and not required" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two}, required: false)
        @cli = TestCLI.new
        expect do
          expect(@cli.parse_options([])).to eql []
        end.to_not raise_error
      end

      it "exit if option is nil and required" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two}, required: true)
        @cli = TestCLI.new
        expect(lambda { @cli.parse_options([]) }).to raise_error(SystemExit)
      end

      it "raises ArgumentError if options key :in is not an array" do
        TestCLI.option(:inclusion, short: "-i val", in: "foo", required: true)
        @cli = TestCLI.new
        expect(lambda { @cli.parse_options(["-i", "three"]) }).to raise_error(ArgumentError)
      end

      it "doesn't exit if option is included in the list" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two}, required: true)
        @cli = TestCLI.new
        @cli.parse_options(["-i", "one"])
        expect(@cli.config[:inclusion]).to eql("one")
      end

      it "changes description if :in key is specified with a single value" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one}, description: "desc", required: false)
        @cli = TestCLI.new
        @cli.parse_options(["-i", "one"])
        expect(@cli.options[:inclusion][:description]).to eql("desc (valid options: 'one')")
      end

      it "changes description if :in key is specified with 2 values" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two}, description: "desc", required: false)
        @cli = TestCLI.new
        @cli.parse_options(["-i", "one"])
        expect(@cli.options[:inclusion][:description]).to eql("desc (valid options: 'one' or 'two')")
      end

      it "changes description if :in key is specified with 3 values" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two three}, description: "desc", required: false)
        @cli = TestCLI.new
        @cli.parse_options(["-i", "one"])
        expect(@cli.options[:inclusion][:description]).to eql("desc (valid options: 'one', 'two', or 'three')")
      end

      it "doesn't exit if a required option is specified" do
        TestCLI.option(:require_me, short: "-r", boolean: true, required: true)
        @cli = TestCLI.new
        @cli.parse_options(["-r"])
        expect(@cli.config[:require_me]).to be true
      end

      it "doesn't exit if a required boolean option is specified and false" do
        TestCLI.option(:require_me, long: "--[no-]req", boolean: true, required: true)
        @cli = TestCLI.new
        @cli.parse_options(["--no-req"])
        expect(@cli.config[:require_me]).to be false
      end

      it "doesn't exit if a required option is specified and empty" do
        TestCLI.option(:require_me, short: "-r VALUE", required: true)
        @cli = TestCLI.new
        @cli.parse_options(["-r", ""])
        expect(@cli.config[:require_me]).to eql("")
      end

      it "preserves all of the command line arguments, ARGV" do
        TestCLI.option(:config_file, short: "-c CONFIG")
        @cli = TestCLI.new
        argv_old = ARGV.dup
        ARGV.replace ["-c", "foo.rb"]
        @cli.parse_options
        expect(ARGV).to eql(["-c", "foo.rb"])
        ARGV.replace argv_old
      end

      it "preserves and return any un-parsed elements" do
        TestCLI.option(:party, short: "-p LOCATION")
        @cli = TestCLI.new
        expect(@cli.parse_options([ "easy", "-p", "opscode", "hard" ])).to eql(%w{easy hard})
        expect(@cli.cli_arguments).to eql(%w{easy hard})
      end

      describe "with non-deprecated and deprecated options" do
        let(:cli) { TestCLI.new }
        before do
          TestCLI.option(:option_a, long: "--[no-]option-a", boolean: true)
          TestCLI.option(:option_b, short: "-b ARG", in: %w{a b c})
          TestCLI.option(:option_c, short: "-c ARG")
        end

        context "when someone injects an unexpected value into 'config'" do
          before do
            cli.config[:surprise] = true
          end
          it "parses and preserves both known and unknown config values" do
            cli.parse_options(%w{--option-a})
            expect(cli.config[:surprise]).to eql true
            expect(cli.config[:option_a]).to eql true
          end

        end

        context "when the deprecated option has a replacement" do

          context "and a value_mapper is provided" do
            before do
              TestCLI.deprecated_option(:option_x,
                long: "--option-x ARG",
                replacement: :option_b,
                value_mapper: Proc.new { |val| val == "valid" ? "a" : "xxx" } )
            end

            it "still checks the replacement's 'in' validation list" do
              expect { cli.parse_options(%w{--option-x invalid}) }.to raise_error SystemExit
            end

            it "sets the mapped value in the replacement option and the deprecated value in the deprecated option" do
              cli.parse_options(%w{--option-x valid})
              expect(cli.config[:option_x]).to eql("valid")
              expect(cli.config[:option_b]).to eql("a")
            end
          end

          context "and a value_mapper is not provided" do
            context "and keep is set to false in the deprecated option" do
              before do
                TestCLI.deprecated_option(:option_x,
                  long: "--option-x ARG",
                  replacement: :option_c,
                  keep: false)
              end
              it "captures the replacement value, but does not set the deprecated value" do
                cli.parse_options %w{--option-x blah}
                expect(cli.config.key?(:option_x)).to eql false
                expect(cli.config[:option_c]).to eql "blah"
              end
            end

            context "and the replacement and deprecated are both boolean" do
              before do
                TestCLI.deprecated_option(:option_x, boolean: true,
                                          long: "--[no-]option-x",
                                          replacement: :option_a)
              end
              it "sets original and replacement to true when the deprecated flag is used" do
                cli.parse_options(%w{--option-x})
                expect(cli.config[:option_x]).to eql true
                expect(cli.config[:option_a]).to eql true
              end
              it "sets the original and replacement to false when the negative deprecated flag is used" do
                cli.parse_options(%w{--no-option-x})
                expect(cli.config[:option_x]).to eql false
                expect(cli.config[:option_a]).to eql false
              end
            end

            context "when the replacement does not accept a value" do
              before do
                TestCLI.deprecated_option(:option_x,
                  long: "--option-x ARG",
                  replacement: :option_c)
              end

              it "will still set the value because you haven't given a custom value mapper to set a true/false value" do
                cli.parse_options(%w{--option-x BLAH})
                expect(cli.config[:option_c]).to eql("BLAH")
              end
            end
          end
        end

        context "when the deprecated option does not have a replacement" do
          before do
            TestCLI.deprecated_option(:option_x, short: "-x")
          end
          it "warns about the deprecated option being removed" do
            expect { TestCLI.new.parse_options(%w{-x}) }.to output(/removed in a future release/).to_stdout
          end
        end
      end
    end
  end

  context "when configured to separate default options" do
    before do
      TestCLI.use_separate_default_options true
      TestCLI.option(:defaulter, short: "-D SOMETHING", default: "this is the default")
      @cli = TestCLI.new
    end

    it "sets default values on the `default` hash" do
      @cli.parse_options([])
      expect(@cli.default_config[:defaulter]).to eql("this is the default")
      expect(@cli.config[:defaulter]).to be_nil
    end

    it "sets parsed values on the `config` hash" do
      @cli.parse_options(%w{-D not-default})
      expect(@cli.default_config[:defaulter]).to eql("this is the default")
      expect(@cli.config[:defaulter]).to eql("not-default")
    end

  end

  context "when subclassed" do
    before do
      TestCLI.options = { arg1: { boolean: true } }
    end

    it "retains previously defined options from parent" do
      class T1 < TestCLI
        option :arg2, boolean: true
      end
      expect(T1.options[:arg1]).to be_a(Hash)
      expect(T1.options[:arg2]).to be_a(Hash)
      expect(TestCLI.options[:arg2]).to be_nil
    end

    it "isn't able to modify parent classes options" do
      class T2 < TestCLI
        option :arg2, boolean: true
      end
      T2.options[:arg1][:boolean] = false
      expect(T2.options[:arg1][:boolean]).to be false
      expect(TestCLI.options[:arg1][:boolean]).to be true
    end

    it "passes its options onto child" do
      class T3 < TestCLI
        option :arg2, boolean: true
      end
      class T4 < T3
        option :arg3, boolean: true
      end
      3.times do |i|
        expect(T4.options["arg#{i + 1}".to_sym]).to be_a(Hash)
      end
    end

    it "also works with an option that's an array" do
      class T5 < TestCLI
        option :arg2, default: []
      end

      class T6 < T5
      end

      expect(T6.options[:arg2]).to be_a(Hash)
    end

  end

end

#  option :config_file,
#    :short => "-c CONFIG",
#    :long  => "--config CONFIG",
#    :default => 'config.rb',
#    :description => "The configuration file to use"
#
#  option :log_level,
#    :short => "-l LEVEL",
#    :long  => "--log_level LEVEL",
#    :description => "Set the log level (debug, info, warn, error, fatal)",
#    :required => true,
#    :proc => nil
#
#  option :help,
#    :short => "-h",
#    :long => "--help",
#    :description => "Show this message",
#    :on => :tail,
#    :boolean => true,
#    :show_options => true,
#    :exit => 0
