# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simple_state_machine/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Elad Meidar"]
  gem.email         = ["elad@eizesus.com"]
  gem.description   = "A simple state machine for Fiverr.com"
  gem.summary       = "A simple lightweight state machine"
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "simple_state_machine"
  gem.require_paths = ["lib"]
  gem.version       = SimpleStateMachine::VERSION
end
