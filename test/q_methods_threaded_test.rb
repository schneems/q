require 'test_helper'

class QmethodsThreadedTest < Test::Unit::TestCase

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
    User.expects(:bar).with("a", "b", "c").twice

    usr = User
    usr.queue.bar("a", "b", "c")

    usr = User.new
    usr.queue.bar("a", "b", "c")
  end

  def test_early_returns_do_not_blow_up
    Foo.expects(:bar).once
    Foo.queue.early_return_if false
    Foo.queue.early_return_if true
  end
end
