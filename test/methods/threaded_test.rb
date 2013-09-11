require 'test_helper'

# TODO: seperate threaded tests from Q general regession tests in this file
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


class ThreadedTest < Test::Unit::TestCase

  def setup
    Q.queue_config.inline = true
  end

  def teardown
    Q.queue_config.inline = false
  end

  def test_queue_is_defined
    assert_match  "foo", User.queue.methods.join(', ')
  end

  def test_dequeue
    args = [1,2,3]
    User.expects(:bar).with(args).twice

    user = User
    user.queue.bar(args)

    user = User.new
    user.queue.bar(args)
  end

  # make sure the namespace works correctly Foo::Bar and User::Bar
  def test_namespacing_works
    refute_equal Foo::Bar, User::Bar
  end

  def test_early_returns_do_not_blow_up
    Foo.expects(:bar).once
    Foo.queue.early_return_if false
    Foo.queue.early_return_if true
  end

  def test_non_inline
    Q.queue_config.inline = false

    args = [1,2,3]
    User.expects(:bar).with(args).twice

    user = User
    user.queue.bar(args)

    user = User.new
    user.queue.bar(args)
  ensure
    Q.queue_config.stop
  end
end
