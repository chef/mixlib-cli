$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rspec'
require 'mixlib/cli'

class TestCLI
  include Mixlib::CLI
end

