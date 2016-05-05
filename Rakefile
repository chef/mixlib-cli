require "bundler"
require "rubygems"
require "rubygems/package_task"
require "rdoc/task"
require "rspec/core/rake_task"

Bundler::GemHelper.install_tasks

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

gem_spec = eval(File.read("mixlib-cli.gemspec"))

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "mixlib-cli #{gem_spec.version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle/rubocop is not available.  gem install chefstyle to do style checking."
end
