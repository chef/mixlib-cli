$:.unshift(File.dirname(__FILE__) + "/lib")
require "mixlib/cli/version"

Gem::Specification.new do |s|
  s.name = "mixlib-cli"
  s.version = Mixlib::CLI::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "LICENSE", "NOTICE"]
  s.summary = "A simple mixin for CLI interfaces, including option parsing"
  s.description = s.summary
  s.author = "Chef Software, Inc."
  s.email = "info@chef.io"
  s.homepage = "https://www.chef.io"
  s.license = "Apache-2.0"

  # Uncomment this to add a dependency
  #s.add_dependency "mixlib-log"
  s.add_development_dependency "rake", "~> 11.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "chefstyle"

  s.require_path = "lib"
  s.files = %w{LICENSE README.md Gemfile Rakefile NOTICE} + Dir.glob("*.gemspec") +
    Dir.glob("{lib,spec}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
end
