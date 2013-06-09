# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque_def/version'

Gem::Specification.new do |gem|
  gem.name          = "resque_def"
  gem.version       = ResqueDef::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{ Defining Resque boilerplate since 2013 }
  gem.summary       = %q{ Defining Resque boilerplate since 2013 }
  gem.homepage      = "https://github.com/heroku/resque_def"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "resque"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
end

