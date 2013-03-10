$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'simpler_state_machine'

require 'rspec'
require 'rspec/autorun'

# require 'ruby-debug'; Debugger.settings[:autoeval] = true; debugger; rubys_debugger = 'annoying'
# require 'ruby-debug/completion'

# Requiring custom spec helpers
Dir[File.dirname(__FILE__) + "/spec_helpers/**/*.rb"].sort.each { |f| require File.expand_path(f) }
#Dir[File.dirname(__FILE__) + "/models/*.rb"].each { |f| require File.expand_path(f) }
require "models/gate"
require 'models/express_gate'
require 'models/king_gate'