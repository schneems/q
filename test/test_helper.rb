Bundler.require

require 'resque'
require 'resque_def'
require 'test/unit'
require "mocha/setup"


Resque.inline = true # for testing, tasks are called automatically


class User
  include ResqueDef

  def self.find(id)
    self.new
  end

  resque_def :foo do
  end

  def self.bar(*args)
  end

  resque_def :bar do |*args|
    User.bar(*args)
  end
end


# make sure the namespace works correctly Foo::Bar and User::Bar
class Foo
  include ResqueDef

  def self.bar(*args)
  end

  resque_def :bar do |*args|
    Foo.bar(*args)
  end

  resque_def :early_return_if do |bool|
    return true if bool
    Foo.bar
  end
end