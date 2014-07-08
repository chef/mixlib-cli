$:.unshift(File.dirname(__FILE__) + '/lib')
require 'mixlib/cli/version'

Gem::Specification.new do |s|
  s.name = "mixlib-cli"
  s.version = Mixlib::CLI::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", 'NOTICE']
  s.summary = "A simple mixin for CLI interfaces, including option parsing"
  s.description = s.summary
  s.author = "Opscode, Inc."
  s.email = "info@opscode.com"
  s.homepage = "http://www.opscode.com"
  
  # Uncomment this to add a dependency
  #s.add_dependency "mixlib-log"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rdoc'
  
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc Rakefile NOTICE) + Dir.glob("{lib,spec}/**/*")
end

