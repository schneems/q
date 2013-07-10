Bundler.require

require 'q'
require 'test/unit'
require "mocha/setup"


class User
  include Q::Methods::Threaded

  def self.find(id)
    self.new
  end

  queue :foo do
  end

  def self.bar(*args)
  end

  queue :bar do |*args|
    User.bar(*args)
  end
end


# make sure the namespace works correctly Foo::Bar and User::Bar
class Foo
  include Q::Methods::Threaded

  def self.bar(*args)
  end

  queue :bar do |*args|
    Foo.bar(*args)
  end

  queue :early_return_if do |bool|
    return true if bool
    Foo.bar
  end
end

class Dummy
end