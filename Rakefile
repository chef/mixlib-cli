require 'rubygems'
require 'rake/gempackagetask'
require 'rspec/core/rake_task'
require 'rdoc/task'

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

gem_spec = eval(File.read("mixlib-cli.gemspec"))

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.gem_spec = gem_spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{gem_spec.name}-#{gem_spec.version}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{gem_spec.name}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "remove build files"
task :clean do
  sh %Q{ rm -f pkg/*.gem }
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mixlib-cli #{gem_spec.version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

