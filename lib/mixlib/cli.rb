#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require 'optparse'

module Mixlib

  # == Mixlib::CLI
  # Adds a DSL for defining command line options and methods for parsing those
  # options to the including class.
  #
  # Mixlib::CLI does some setup in #initialize, so the including class must
  # call `super()` if it defines a custom initializer.
  #
  # === DSL
  # When included, Mixlib::CLI also extends the including class with its
  # ClassMethods, which define the DSL. The primary methods of the DSL are
  # ClassMethods#option, which defines a command line option, and
  # ClassMethods#banner, which defines the "usage" banner.
  #
  # === Parsing
  # Command line options are parsed by calling the instance method
  # #parse_options. After calling this method, the attribute #config will
  # contain a hash of `:option_name => value` pairs.
  module CLI
    
    module InheritMethods
      def inherited(receiver)
        receiver.options = deep_dup(self.options)
        receiver.extend(Mixlib::CLI::InheritMethods)
      end

      def deep_dup(thing)
        new_thing = thing.respond_to?(:dup) ? thing.dup : thing
        if(new_thing.kind_of?(Enumerable))
          if(new_thing.kind_of?(Hash))
            duped = new_thing.map do |key, value|
              [deep_dup(key), deep_dup(value)]
            end
            new_thing = new_thing.class[*duped.flatten]
          else
            new_thing.map!{|value| deep_dup(value)}
          end
        end
        new_thing
      rescue TypeError
        thing
      end
    end
    
    module ClassMethods
      # When this setting is set to +true+, default values supplied to the
      # mixlib-cli DSL will be stored in a separate Hash
      def use_separate_default_options(true_or_false)
        @separate_default_options = true_or_false
      end

      def use_separate_defaults?
        @separate_default_options || false
      end

      # Add a command line option.
      #
      # === Parameters
      # name<Symbol>:: The name of the option to add
      # args<Hash>:: A hash of arguments for the option, specifying how it should be parsed.
      # === Returns
      # true:: Always returns true.
      def option(name, args)
        @options ||= {}
        raise(ArgumentError, "Option name must be a symbol") unless name.kind_of?(Symbol)
        @options[name.to_sym] = args
      end

      # Get the hash of current options.
      #
      # === Returns
      # @options<Hash>:: The current options hash.
      def options
        @options ||= {}
        @options
      end

      # Set the current options hash
      #
      # === Parameters
      # val<Hash>:: The hash to set the options to
      #
      # === Returns
      # @options<Hash>:: The current options hash.
      def options=(val)
        raise(ArgumentError, "Options must recieve a hash") unless val.kind_of?(Hash)
        @options = val
      end

      # Change the banner.  Defaults to:
      #   Usage: #{0} (options)
      #
      # === Parameters
      # bstring<String>:: The string to set the banner to
      #
      # === Returns
      # @banner<String>:: The current banner
      def banner(bstring=nil)
        if bstring
          @banner = bstring
        else
          @banner ||= "Usage: #{$0} (options)"
          @banner
        end
      end
    end

    # Gives the command line options definition as configured in the DSL. These
    # are used by #parse_options to generate the option parsing code. To get
    # the values supplied by the user, see #config.
    attr_accessor :options

    # A Hash containing the values supplied by command line options.
    #
    # The behavior and contents of this Hash vary depending on whether
    # ClassMethods#use_separate_default_options is enabled.
    # ==== use_separate_default_options *disabled*
    # After initialization, +config+ will contain any default values defined
    # via the mixlib-config DSL. When #parse_options is called, user-supplied
    # values (from ARGV) will be merged in.
    # ==== use_separate_default_options *enabled*
    # After initialization, this will be an empty hash. When #parse_options is
    # called, +config+ is populated *only* with user-supplied values.
    attr_accessor :config

    # If ClassMethods#use_separate_default_options is enabled, this will be a
    # Hash containing key value pairs of `:option_name => default_value`
    # (populated during object initialization).
    #
    # If use_separate_default_options is disabled, it will always be an empty
    # hash.
    attr_accessor :default_config

    # Banner for the option parser. If the option parser is printed, e.g., by
    # `puts opt_parser`, this string will be used as the first line.
    attr_accessor :banner

    # The option parser generated from the mixlib-cli DSL. Set to nil on
    # initialize; when #parse_options is called +opt_parser+ is set to an
    # instance of OptionParser. +opt_parser+ can be used to print a help
    # message including the banner and any CLI options via `puts opt_parser`.
    attr_accessor :opt_parser

    # Create a new Mixlib::CLI class.  If you override this, make sure you call super!
    #
    # === Parameters
    # *args<Array>:: The array of arguments passed to the initializer
    #
    # === Returns
    # object<Mixlib::Config>:: Returns an instance of whatever you wanted :)
    def initialize(*args)
      @options = Hash.new
      @config  = Hash.new
      @default_config = Hash.new
      @opt_parser = nil

      # Set the banner
      @banner  = self.class.banner

      # Dupe the class options for this instance
      klass_options = self.class.options
      klass_options.keys.inject(@options) { |memo, key| memo[key] = klass_options[key].dup; memo }

      # If use_separate_defaults? is on, default values go in @default_config
      defaults_container = if self.class.use_separate_defaults?
                             @default_config
                           else
                             @config
                           end

      # Set the default configuration values for this instance
      @options.each do |config_key, config_opts|
        config_opts[:on] ||= :on
        config_opts[:boolean] ||= false
        config_opts[:required] ||= false
        config_opts[:proc] ||= nil
        config_opts[:show_options] ||= false
        config_opts[:exit] ||= nil

        if config_opts.has_key?(:default)
          defaults_container[config_key] = config_opts[:default]
        end
      end

      super(*args)
    end

    # Parses an array, by default ARGV, for command line options (as configured at
    # the class level).
    # === Parameters
    # argv<Array>:: The array of arguments to parse; defaults to ARGV
    #
    # === Returns
    # argv<Array>:: Returns any un-parsed elements.
    def parse_options(argv=ARGV)
      argv = argv.dup
      @opt_parser = OptionParser.new do |opts|
        # Set the banner
        opts.banner = banner

        # Create new options
        options.sort { |a, b| a[0].to_s <=> b[0].to_s }.each do |opt_key, opt_val|
          opt_args = build_option_arguments(opt_val)

          opt_method = case opt_val[:on]
            when :on
              :on
            when :tail
              :on_tail
            when :head
              :on_head
            else
              raise ArgumentError, "You must pass :on, :tail, or :head to :on"
            end

          parse_block =
            Proc.new() do |c|
              config[opt_key] = (opt_val[:proc] && opt_val[:proc].call(c)) || c
              puts opts if opt_val[:show_options]
              exit opt_val[:exit] if opt_val[:exit]
            end

          full_opt = [ opt_method ]
          opt_args.inject(full_opt) { |memo, arg| memo << arg; memo }
          full_opt << parse_block
          opts.send(*full_opt)
        end
      end
      @opt_parser.parse!(argv)

      # Deal with any required values
      options.each do |opt_key, opt_value|
        if opt_value[:required] && !config.has_key?(opt_key)
          reqarg = opt_value[:short] || opt_value[:long]
          puts "You must supply #{reqarg}!"
          puts @opt_parser
          exit 2
        end
      end

      argv
    end

    def build_option_arguments(opt_setting)
      arguments = Array.new

      arguments << opt_setting[:short] if opt_setting.has_key?(:short)
      arguments << opt_setting[:long] if opt_setting.has_key?(:long)

      if opt_setting.has_key?(:description)
        description = opt_setting[:description]
        description << " (required)" if opt_setting[:required]
        arguments << description
      end

      arguments
    end

    def self.included(receiver)
      receiver.extend(Mixlib::CLI::ClassMethods)
      receiver.extend(Mixlib::CLI::InheritMethods)
    end

  end
end
