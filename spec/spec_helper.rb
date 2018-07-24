$TESTING = true
$:.push File.join(File.dirname(__FILE__), "..", "lib")

require "mixlib/cli"

class TestCLI
  include Mixlib::CLI
end

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
end
