# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'q/version'

Gem::Specification.new do |gem|
  gem.name          = "q"
  gem.version       = Q::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{ A universal interface for Ruby queueing backends. }
  gem.summary       = %q{ Use Q to switch betwen queue backends as you please. Simplifies creating and calling background jobs }
  gem.homepage      = "https://github.com/schneems/q"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "proc_to_lambda"
  gem.add_dependency "threaded_in_memory_queue"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "resque"
  gem.add_development_dependency "sidekiq"
  gem.add_development_dependency "delayed_job_active_record"
  gem.add_development_dependency "sqlite3"
end
