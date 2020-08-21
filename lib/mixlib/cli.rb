#
# Author:: Adam Jacob (<adam@chef.io>)
# Copyright:: Copyright (c) 2008-2019 Chef Software, Inc.
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

require "optparse" unless defined?(OptionParser)
require_relative "cli/formatter"
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
  # ClassMethods#option, which defines a command line option;
  # ClassMethods#banner, which defines the "usage" banner;
  # and ClassMethods#deprecated_option, which defines a deprecated command-line option.
  #
  # === Parsing
  # Command line options are parsed by calling the instance method
  # #parse_options. After calling this method, the attribute #config will
  # contain a hash of `:option_name => value` pairs.
  module CLI

    module InheritMethods
      def inherited(receiver)
        receiver.options = deep_dup(options)
        receiver.extend(Mixlib::CLI::InheritMethods)
      end

      # object:: Instance to clone
      # This method will return a "deep clone" of the provided
      # `object`. If the provided `object` is an enumerable type the
      # contents will be iterated and cloned as well.
      def deep_dup(object)
        cloned_object = object.respond_to?(:dup) ? object.dup : object
        if cloned_object.is_a?(Enumerable)
          if cloned_object.is_a?(Hash)
            new_hash = cloned_object.class.new
            cloned_object.each do |key, value|
              cloned_key = deep_dup(key)
              cloned_value = deep_dup(value)
              new_hash[cloned_key] = cloned_value
            end
            cloned_object.replace(new_hash)
          else
            cloned_object.map! do |shallow_instance|
              deep_dup(shallow_instance)
            end
          end
        end
        cloned_object
      rescue TypeError
        # Symbol will happily provide a `#dup` method even though
        # attempts to clone it will result in an exception (atoms!).
        # So if we run into an issue of TypeErrors, just return the
        # original object as we gave our "best effort"
        object
      end

    end

    module ClassMethods
      # When this setting is set to +true+, default values supplied to the
      # mixlib-cli DSL will be stored in a separate Hash
      def use_separate_default_options(true_or_false)
        @separate_default_options = true_or_false
      end

      def use_separate_defaults?
        @separate_default_options ||= false
      end

      # Add a command line option.
      #
      # === Parameters
      # name<Symbol>:: The name of the option to add
      # args<Hash>:: A hash of arguments for the option, specifying how it should be parsed.
      #   Supported arguments:
      #     :short   - The short option, just like from optparse. Example: "-l LEVEL"
      #     :long    - The long option, just like from optparse. Example: "--level LEVEL"
      #     :description - The description for this item, just like from optparse.
      #     :default - A default value for this option.  Default values will be populated
      #     on parse into `config` or `default_default`, depending `use_separate_defaults`
      #     :boolean - indicates the flag is a boolean. You can use this if the flag takes no arguments
      #                The config value will be set to 'true' if the flag is provided on the CLI and this
      #                argument is set to true. The config value will be set to false only
      #                if it has a default value of false
      #     :required - When set, the option is required.  If the command is run without this option,
      #                it will print a message informing the user of the missing requirement, and exit. Default is false.
      #     :proc     - Proc that will be invoked if the human has specified this option.
      #                 Two forms are supported:
      #                 Proc/1 - provided value is passed in.
      #                 Proc/2 - first argument is provided value. Second is the cli flag option hash.
      #                 Both versions return the value to be assigned to the option.
      #     :show_options - this option is designated as one that shows all supported options/help when invoked.
      #     :exit     - exit your program with the exit code when this option is given. Example: 0
      #     :in       - array containing a list of valid values. The value provided at run-time for the option is
      #                 validated against this. If it is not in the list, it will print a message and exit.
      #     :on :head OR :tail - force this option to display at the beginning or end of the
      #                          option list, respectively
      # =
      # @return <Hash> :: the config hash for the created option
      # i
      def option(name, args)
        @options ||= {}
        raise(ArgumentError, "Option name must be a symbol") unless name.is_a?(Symbol)

        @options[name.to_sym] = args
      end

      # Declare a deprecated option
      #
      # Add a deprecated command line option.
      #
      # name<Symbol> :: The name of the deprecated option
      # replacement<Symbol> :: The name of the option that replaces this option.
      # long<String> :: The original long flag name, or flag name with argument, eg "--user USER"
      # short<String>  :: The original short-form flag name, eg "-u USER"
      # boolean<String> :: true if this is a boolean flag, eg "--[no-]option".
      # value_mapper<Proc/1> :: a block that accepts the original value from the deprecated option,
      #                   and converts it to a value suitable for the new option.
      #                   If not provided, the value provided to the deprecated option will be
      #                   assigned directly to the converted option.
      # keep<Boolean> :: Defaults to true, this ensure sthat `options[:deprecated_flag]` is
      #                  populated when the deprecated flag is used. If set to false,
      #                  only the value in `replacement` will be set.  Results undefined
      #                  if no replacement is provided. You can use this to enforce the transition
      #                  to non-deprecated keys in your code.
      #
      # === Returns
      # <Hash> :: The config hash for the created option.
      def deprecated_option(name,
        replacement: nil,
        long: nil,
        short: nil,
        boolean: false,
        value_mapper: nil,
        keep: true)

        description = if replacement
                        replacement_cfg = options[replacement]
                        display_name = CLI::Formatter.combined_option_display_name(replacement_cfg[:short], replacement_cfg[:long])
                        "This flag is deprecated. Use #{display_name} instead."
                      else
                        "This flag is deprecated and will be removed in a future release."
                      end
        value_mapper ||= Proc.new { |v| v }

        option(name,
          long: long,
          short: short,
          boolean: boolean,
          description: description,
          on: :tail,
          deprecated: true,
          keep: keep,
          replacement: replacement,
          value_mapper: value_mapper)
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
        raise(ArgumentError, "Options must recieve a hash") unless val.is_a?(Hash)

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
      def banner(bstring = nil)
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

    # Any arguments which were not parsed and placed in "config"--the leftovers.
    attr_accessor :cli_arguments

    # Banner for the option parser. If the option parser is printed, e.g., by
    # `puts opt_parser`, this string will be used as the first line.
    attr_accessor :banner

    # Create a new Mixlib::CLI class.  If you override this, make sure you call super!
    #
    # === Parameters
    # *args<Array>:: The array of arguments passed to the initializer
    #
    # === Returns
    # object<Mixlib::Config>:: Returns an instance of whatever you wanted :)
    def initialize(*args)
      @options = {}
      @config  = {}
      @default_config = {}
      @opt_parser = nil

      # Set the banner
      @banner = self.class.banner

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
        config_opts[:in] ||= nil
        if config_opts.key?(:default)
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
    def parse_options(argv = ARGV, show_deprecations: true)
      argv = argv.dup
      opt_parser.parse!(argv)
      # Do this before our custom validations, so that custom
      # validations apply to any converted deprecation values;
      # but after parse! so that everything is populated.
      handle_deprecated_options(show_deprecations)

      # Deal with any required values
      options.each do |opt_key, opt_config|
        if opt_config[:required] && !config.key?(opt_key)
          reqarg = opt_config[:short] || opt_config[:long]
          puts "You must supply #{reqarg}!"
          puts @opt_parser
          exit 2
        end
        if opt_config[:in]
          unless opt_config[:in].is_a?(Array)
            raise(ArgumentError, "Options config key :in must receive an Array")
          end

          if config[opt_key] && !opt_config[:in].include?(config[opt_key])
            reqarg = Formatter.combined_option_display_name(opt_config[:short], opt_config[:long])
            puts "#{reqarg}: #{config[opt_key]} is not one of the allowed values: #{Formatter.friendly_opt_list(opt_config[:in])}"
            # TODO - get rid of this. nobody wants to be spammed with a  ton of information, particularly since we just told them the exact problem and how to fix it.
            puts @opt_parser
            exit 2
          end
        end
      end

      @cli_arguments = argv
      argv
    end

    # The option parser generated from the mixlib-cli DSL. +opt_parser+ can be
    # used to print a help message including the banner and any CLI options via
    # `puts opt_parser`.
    # === Returns
    # opt_parser<OptionParser>:: The option parser object.
    def opt_parser
      @opt_parser ||= OptionParser.new do |opts|
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
            Proc.new do |c|
              config[opt_key] = if opt_val[:proc]
                                  if opt_val[:proc].arity == 2
                                    # New hotness to allow for reducer-style procs.
                                    opt_val[:proc].call(c, config[opt_key])
                                  else
                                    # Older single-argument proc.
                                    opt_val[:proc].call(c)
                                  end
                                else
                                  # No proc.
                                  c
                                end
              puts opts if opt_val[:show_options]
              exit opt_val[:exit] if opt_val[:exit]
            end

          full_opt = [ opt_method ]
          opt_args.inject(full_opt) { |memo, arg| memo << arg; memo }
          full_opt << parse_block
          opts.send(*full_opt)
        end
      end
    end

    # Iterates through options declared as deprecated,
    # maps values to their replacement options,
    # and prints deprecation warnings.
    #
    # @return NilClass
    def handle_deprecated_options(show_deprecations)
      merge_in_values = {}
      config.each_key do |opt_key|
        opt_cfg = options[opt_key]

        # Deprecated entries do not have defaults so no matter what
        # separate_default_options are set, if we see a 'config'
        # entry that contains a deprecated indicator, then the option was
        # explicitly provided by the caller.
        #
        # opt_cfg may not exist if an inheriting application
        # has directly inserted values info config.
        next unless opt_cfg && opt_cfg[:deprecated]

        replacement_key = opt_cfg[:replacement]
        if replacement_key
          # This is the value passed into the deprecated flag. We'll use
          # the declared value mapper (defaults to return the same value if caller hasn't
          # provided a mapper).
          deprecated_val = config[opt_key]

          # We can't modify 'config' since we're iterating it, apply updates
          # at the end.
          merge_in_values[replacement_key] = opt_cfg[:value_mapper].call(deprecated_val)
          config.delete(opt_key) unless opt_cfg[:keep]
        end

        # Warn about the deprecation.
        if show_deprecations
          # Description is also the deprecation message.
          display_name = CLI::Formatter.combined_option_display_name(opt_cfg[:short], opt_cfg[:long])
          puts "#{display_name}: #{opt_cfg[:description]}"
        end
      end
      config.merge!(merge_in_values)
      nil
    end

    def build_option_arguments(opt_setting)
      arguments = []

      arguments << opt_setting[:short] if opt_setting[:short]
      arguments << opt_setting[:long] if opt_setting[:long]
      if opt_setting.key?(:description)
        description = opt_setting[:description].dup
        description << " (required)" if opt_setting[:required]
        description << " (valid options: #{Formatter.friendly_opt_list(opt_setting[:in])})" if opt_setting[:in]
        opt_setting[:description] = description
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
