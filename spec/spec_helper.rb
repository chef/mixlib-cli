$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'mixlib/cli'

class TestCLI
  include Mixlib::CLI
end

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.warnings = true
end

