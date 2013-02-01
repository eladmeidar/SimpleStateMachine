# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simple_state_machine/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Elad Meidar"]
  gem.email         = ["elad@eizesus.com"]
  gem.description   = "A simple state machine that supports enum"
  gem.summary       = "A simple lightweight state machine that uses an enum type to store states"
  gem.homepage      = "http://devandpencil.herokuapp.com/blog/2013/01/30/simplestatemachine-a-simple-enum-based-state-machine-for-ruby/"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "simple_state_machine"
  gem.require_paths = ["lib"]
  gem.version       = SimpleStateMachine::VERSION

  gem.add_development_dependency 'activerecord'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sdoc'
  gem.add_development_dependency 'rspec', '~> 2.0'
  gem.add_development_dependency 'rr'
  gem.add_development_dependency 'shoulda'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'ruby-debug'
  gem.add_development_dependency 'ruby-debug-completion'
end
