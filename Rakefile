require "bundler/gem_tasks"
require "rspec/core/rake_task"

task default: [:style, :spec]

Bundler::GemHelper.install_tasks

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle/rubocop is not available. bundle install first to make sure all dependencies are installed."
end

begin
  require "yard"
  YARD::Rake::YardocTask.new(:doc)
rescue LoadError
  puts "yard is not available. bundle install first to make sure all dependencies are installed."
end
