$TESTING = true

require "mixlib/cli"

RSpec.configure do |config|
  # Use documentation format
  config.formatter = "doc"

  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # run the examples in random order
  config.order = :rand

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.warnings = true

  config.before(:each) do
    # create a fresh TestCLI class on every example, so that examples never
    # pollute global variables and create ordering issues
    Object.send(:remove_const, "TestCLI") if Object.const_defined?("TestCLI")
    TestCLI = Class.new
    TestCLI.send(:include, Mixlib::CLI)
  end
end
