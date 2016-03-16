# Mixlib::CLI

[![Build Status Master](https://travis-ci.org/chef/mixlib-cli.svg?branch=master)](https://travis-ci.org/chef/mixlib-cli) [![Gem Version](https://badge.fury.io/rb/mixlib-cli.svg)](https://badge.fury.io/rb/mixlib-cli)

Mixlib::CLI provides a class-based command line option parsing object, like the one used in Chef, Ohai and Relish. To use in your project:

```ruby
require 'rubygems'
require 'mixlib/cli'

class MyCLI
  include Mixlib::CLI

  option :config_file,
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => 'config.rb',
    :description => "The configuration file to use"

  option :log_level,
    :short => "-l LEVEL",
    :long  => "--log_level LEVEL",
    :description => "Set the log level (debug, info, warn, error, fatal)",
    :required => true,
    :in => ['debug', 'info', 'warn', 'error', 'fatal'],
    :proc => Proc.new { |l| l.to_sym }

  option :help,
    :short => "-h",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0

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
  def run(argv=ARGV)
    parse_options(argv)
    MyConfig.merge!(config)
  end
end

c = MyCLI.new
# ARGV = [ '-l', 'debug' ]
c.run
MyConfig[:log_level] # :debug
```

Available arguments to 'option':

- `:short`: The short option, just like from optparse. Example: "-l LEVEL"
- `:long`: The long option, just like from optparse.  Example: "--level LEVEL"
- `:description`: The description for this item, just like from optparse.
- `:default`: A default value for this option
- `:required`: Prints a message informing the user of the missing requirement, and exits.  Default is false.
- `:on`: Set to :tail to appear at the end, or
- :head to appear at the top. :boolean:: If this option takes no arguments, set this to true.
- `:show_options`: If you want the option list printed when this option is called, set this to true.
- `:exit`: Exit your program with the exit code when this option is specified. Example: 0
- `:proc`: If set, the configuration value will be set to the return value of this proc.
- `:in`: An array containing the list of accepted values

If you need access to the leftover options that aren't captured in the config, you can get at them through +cli_arguments+ (referring to the above definition of MyCLI).

```ruby
# ARGV = [ '-c', 'foo.rb', '-l', 'debug', 'file1', 'file2', 'file3' ]
cli = MyCLI.new
cli.parse_options
cli.cli_arguments # [ 'file1', 'file2', 'file3' ]
```
