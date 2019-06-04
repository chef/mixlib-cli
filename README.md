# Mixlib::CLI

 [![Gem Version](https://badge.fury.io/rb/mixlib-cli.svg)](https://badge.fury.io/rb/mixlib-cli)

**Umbrella Project**: [Chef Foundation](https://github.com/chef/chef-oss-practices/blob/master/projects/chef-foundation.md)

**Project State**: [Active](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md#active)

**Issues [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

**Pull Request [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

Mixlib::CLI provides a class-based command line option parsing object, like the one used in Chef, Ohai and Relish. To use in your project:

```ruby
require "mixlib/cli"

class MyCLI
  include Mixlib::CLI

  option :config_file,
    short: "-c CONFIG",
    long: "--config CONFIG",
    default: "config.rb",
    description: "The configuration file to use"

  option :log_level,
    short: "-l LEVEL",
    long: "--log_level LEVEL",
    description: "Set the log level (debug, info, warn, error, fatal)",
    required: true,
    in: [:debug, :info, :warn, :error, :fatal],
    proc: Proc.new { |l| l.to_sym }

  option :help,
    short: "-h",
    long: "--help",
    description: "Show this message",
    on: :tail,
    boolean: true,
    show_options: true,
    exit: 0

end

# ARGV = [ '-c', 'foo.rb', '-l', 'debug' ]
cli = MyCLI.new
cli.parse_options
cli.config[:config_file] # 'foo.rb'
cli.config[:log_level]   # :debug
```

If you are using this in conjunction with Mixlib::Config, you can do something like this (building on the above definition):

```ruby
class MyConfig
  extend(Mixlib::Config)

  log_level   :info
  config_file "default.rb"
end

class MyCLI
  def run(argv = ARGV)
    parse_options(argv)
    MyConfig.merge!(config)
  end
end

c = MyCLI.new
# ARGV = [ '-l', 'debug' ]
c.run
MyConfig[:log_level] # :debug
```

For supported arguments to `option`, see the function documentation in [lib/mixlib/cli.rb](lib/mixlib/cli.rb).


If you need access to the leftover options that aren't captured in the config, you can get at them through +cli_arguments+ (referring to the above definition of MyCLI).

```ruby
# ARGV = [ '-c', 'foo.rb', '-l', 'debug', 'file1', 'file2', 'file3' ]
cli = MyCLI.new
cli.parse_options
cli.cli_arguments # [ 'file1', 'file2', 'file3' ]
```

## Deprecating CLI Options

mixlib-cli 2.1.0 and later supports declaring options as deprecated.  Using a deprecated option
will result in a warning message being displayed.  If a deprecated flag is supplied,
its value is assigned to the replacement flag.  You can control this assignment by specifying a
`value_mapper` function in the arguments (see example below, and function docs)


Usage notes (see docs for arguments to `Mixlib::CLI::ClassMethods#deprecated_option` for more):

 * Define deprecated items last, after all non-deprecated items have been defined.
 You will see errors if your deprecated item references a `replacement` that hasn't been defined yet.
 * deprecated\_option only takes a subset of 'option' configuration.  You can only specify `short`, `long` - these should
   map to the short/long values of the option from before its deprecation.
   * item description will automatically be generated along the lines of "-f/--flag is deprecated. Use -n/--new-flag instead."
   * if the `replacement` argument is not given, item description will look like "-f/--flag is deprecated and will be removed in a future release"

### Example

Given the following example:

```ruby

# mycli.rb

class MyCLI
  include Mixlib::CLI


  option :arg_not_required,
    description: "This takes no argument.",
    long: "--arg-not-required",
    short: "-n"

  option :arg_required,
    description: "This takes an argument.",
    long: "--arg-required ARG",
    short: "-a",
    in: ["a", "b", "c"]

  deprecated_option :dep_one,
    short: "-1",
    long: "--dep-one",
    # this deprecated option maps to the '--arg-not-required' option:
    replacement: :arg_not_required,
    # Do not keep 'dep_one' in `config` after parsing.
    keep: false

  deprecated_option :dep_two,
    short: "-2",
    long: "--dep-two ARG",
    replacement: :arg_required,
    # will map the  given value to a valid value for `--arg-required`.
    value_mapper: Proc.new { |arg|
      case arg
      when "q"; "invalid" # We'll use this to show validation still works
      when "z"; "a"
      when "x"; "b"
      else
        "c"
      end
    }

end

c = MyCLI.new()
c.parse_options

puts "arg_required: #{c.config[:arg_required]}" if c.config.key? :arg_required
puts "arg_not_required: #{c.config[:arg_not_required]}" if c.config.key? :arg_not_required
puts "dep_one: #{c.config[:dep_one]}" if c.config.key? :dep_one
puts "dep_two: #{c.config[:dep_two]}" if c.config.key? :dep_two

```

In this example, --dep-one will be used.  Note that dep_one will not have a value of its own in
`options` because `keep: false` was given to the deprecated option.

```bash

$ ruby mycli.rb --dep-one

-1/--dep-one: This flag is deprecated. Use -n/--arg-not-required instead
arg_not_required: true

```

In this example, the value provided to dep-two will be converted to a value
that --arg-required will accept,a nd populate `:arg\_required` with

```bash

$ ruby mycli.rb --dep-two z # 'q' maps to 'invalid' in the value_mapper proc above

-2/--dep-two: This flag is deprecated. Use -a/--arg-required instead.

arg_required: a # The value is mapped to its replacement using the function provided.
dep_two: z  # the deprected value is kept by default
```

In this example, the value provided to dep-two will be converted to a value
that --arg-required will reject, showing how content rules are applied even when
the input is coming from a deprecated option:

```bash
$ ruby mycli.rb --dep-two q

-2/--dep-two: This flag is deprecated. Use -a/--arg-required instead.
-a/--arg-required: invalid is not one of the allowed values: 'a', 'b', or 'c'

```
## Documentation

Class and module documentation is maintained using YARD. You can generate it by running:

```
rake docs
```

You can serve them locally with live refresh using:

```
bundle exec yard server --reload
```

## Contributing

For information on contributing to this project please see our [Contributing Documentation](https://github.com/chef/chef/blob/master/CONTRIBUTING.md)

## License & Copyright

- Copyright:: Copyright (c) 2008-2018 Chef Software, Inc.
- License:: Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
