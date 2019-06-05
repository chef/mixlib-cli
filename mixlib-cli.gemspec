$:.unshift(File.dirname(__FILE__) + "/lib")
require "mixlib/cli/version"

Gem::Specification.new do |s|
  s.name = "mixlib-cli"
  s.version = Mixlib::CLI::VERSION
  s.summary = "A simple mixin for CLI interfaces, including option parsing"
  s.description = s.summary
  s.author = "Chef Software, Inc."
  s.email = "info@chef.io"
  s.homepage = "https://github.com/chef/mixlib-cli"
  s.license = "Apache-2.0"
  s.required_ruby_version = ">= 2.4"

  s.require_path = "lib"
  s.files = %w{LICENSE NOTICE} + Dir.glob("lib/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
end
