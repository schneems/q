Bundler.require

require 'q'
require 'test/unit'
require "mocha/setup"


Dir.glob("test/support/*.rb").each do |support|
  require support.gsub('test/', '').gsub('.rb', '')
end

class Dummy
end

def kill_process(pid)
  Process.kill :INT, pid
end

if defined?(Rake)
  task = Rake::Task.define_task("environment") do
  end
end
