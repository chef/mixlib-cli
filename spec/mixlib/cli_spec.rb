#
# Author:: Adam Jacob (<adam@chef.io>)
# Copyright:: Copyright (c) 2008-2016 Chef Software, Inc.
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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

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

    describe "options" do
      it "returns the current options hash" do
        TestCLI.option(:config_file, short: "-c CONFIG")
        expect(TestCLI.options).to eql({ config_file: { short: "-c CONFIG" } })
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

  context "when configured with default single-parsed-options-hash behavior" do

    before(:each) do
      @cli = TestCLI.new
    end

    describe "initialize" do
      it "sets the banner to the class defined banner" do
        expect(@cli.banner).to eql(TestCLI.banner)
      end

      it "sets the options to the class defined options, plus defaults" do
        TestCLI.option(:config_file, short: "-l LOG")
        cli = TestCLI.new
        expect(cli.options).to eql({
          config_file: {
            short: "-l LOG",
            on: :on,
            boolean: false,
            required: false,
            proc: nil,
            show_options: false,
            exit: nil,
            in: nil,
          },
        })
      end

      it "sets the default parsed_options value for any options that include it" do
        TestCLI.option(:config_file, short: "-l LOG", default: :debug)
        @cli = TestCLI.new
        expect(@cli.parsed_options[:config_file]).to eql(:debug)
      end

      it "sets the historical value config" do
        TestCLI.option(:config_file, short: "-l LOG", default: :debug)
        @cli = TestCLI.new
        expect(@cli.parsed_options).to eql(@cli.config)
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
      it "sets the corresponding parsed_options value for non-boolean arguments" do
        TestCLI.option(:config_file, short: "-c CONFIG")
        @cli = TestCLI.new
        @cli.parse_options([ "-c", "foo.rb" ])
        expect(@cli.parsed_options[:config_file]).to eql("foo.rb")
      end

      it "sets the corresponding parsed_options value according to a supplied proc" do
        TestCLI.option(:number,
          short: "-n NUMBER",
          proc: Proc.new { |c| c.to_i + 2 }
        )
        @cli = TestCLI.new
        @cli.parse_options([ "-n", "2" ])
        expect(@cli.parsed_options[:number]).to eql(4)
      end

      it "passes the existing value to two-argument procs" do
        TestCLI.option(:number,
          short: "-n NUMBER",
          proc: Proc.new { |value, existing| existing ||= []; existing << value; existing }
        )
        @cli = TestCLI.new
        @cli.parse_options([ "-n", "2", "-n", "3" ])
        expect(@cli.parsed_options[:number]).to eql(%w{2 3})
      end

      it "sets the corresponding parsed_options value to true for boolean arguments" do
        TestCLI.option(:i_am_boolean, short: "-i", boolean: true)
        @cli = TestCLI.new
        @cli.parse_options([ "-i" ])
        expect(@cli.parsed_options[:i_am_boolean]).to be true
      end

      it "sets the corresponding parsed_options value to false when a boolean is prefixed with --no" do
        TestCLI.option(:i_am_boolean, long: "--[no-]bool", boolean: true)
        @cli = TestCLI.new
        @cli.parse_options([ "--no-bool" ])
        expect(@cli.parsed_options[:i_am_boolean]).to be false
      end

      it "exits if a parsed_options option has :exit set" do
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
        expect(@cli.parsed_options[:inclusion]).to eql("one")
      end

      it "changes description if :in key is specified" do
        TestCLI.option(:inclusion, short: "-i val", in: %w{one two}, description: "desc", required: false)
        @cli = TestCLI.new
        @cli.parse_options(["-i", "one"])
        expect(@cli.options[:inclusion][:description]).to eql("desc (included in ['one', 'two'])")
      end

      it "doesn't exit if a required option is specified" do
        TestCLI.option(:require_me, short: "-r", boolean: true, required: true)
        @cli = TestCLI.new
        @cli.parse_options(["-r"])
        expect(@cli.parsed_options[:require_me]).to be true
      end

      it "doesn't exit if a required boolean option is specified and false" do
        TestCLI.option(:require_me, long: "--[no-]req", boolean: true, required: true)
        @cli = TestCLI.new
        @cli.parse_options(["--no-req"])
        expect(@cli.parsed_options[:require_me]).to be false
      end

      it "doesn't exit if a required option is specified and empty" do
        TestCLI.option(:require_me, short: "-r VALUE", required: true)
        @cli = TestCLI.new
        @cli.parse_options(["-r", ""])
        expect(@cli.parsed_options[:require_me]).to eql("")
      end

      it "preserves all of the commandline arguments, ARGV" do
        TestCLI.option(:config_file, short: "-c CONFIG")
        @cli = TestCLI.new
        argv_old = ARGV.dup
        ARGV.replace ["-c", "foo.rb"]
        @cli.parse_options()
        expect(ARGV).to eql(["-c", "foo.rb"])
        ARGV.replace argv_old
      end

      it "preserves and return any un-parsed elements" do
        TestCLI.option(:party, short: "-p LOCATION")
        @cli = TestCLI.new
        expect(@cli.parse_options([ "easy", "-p", "opscode", "hard" ])).to eql(%w{easy hard})
        expect(@cli.cli_arguments).to eql(%w{easy hard})
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
      expect(@cli.default_options[:defaulter]).to eql("this is the default")
      expect(@cli.parsed_options[:defaulter]).to be_nil
    end

    it "sets parsed values on the `parsed_options` hash" do
      @cli.parse_options(%w{-D not-default})
      expect(@cli.default_options[:defaulter]).to eql("this is the default")
      expect(@cli.parsed_options[:defaulter]).to eql("not-default")
    end

    it "sets the historical value default_config" do
      @cli.parse_options([])
      expect(@cli.default_options).to eql(@cli.default_config)
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
