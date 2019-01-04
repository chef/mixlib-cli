$:.unshift(File.dirname(__FILE__) + "/lib")
require "mixlib/cli/version"

Gem::Specification.new do |s|
  s.name = "mixlib-cli"
  s.version = Mixlib::CLI::VERSION
  s.extra_rdoc_files = ["README.md", "LICENSE", "NOTICE"]
  s.summary = "A simple mixin for CLI interfaces, including option parsing"
  s.description = s.summary
  s.author = "Chef Software, Inc."
  s.email = "info@chef.io"
  s.homepage = "https://www.chef.io"
  s.license = "Apache-2.0"
  s.required_ruby_version = ">= 2.5"

  s.require_path = "lib"
  s.files = %w{LICENSE README.md Gemfile Rakefile NOTICE} + Dir.glob("*.gemspec") +
    Dir.glob("{lib,spec}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
end
