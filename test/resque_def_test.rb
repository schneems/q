require 'test_helper'

class ResqueDefTest < Test::Unit::TestCase

  def setup
  end

  def test_enqueue
    Resque.expects(:enqueue).with(User::Foo, 1,2,3).once
    Resque.expects(:enqueue).with(User::Foo, 4,5,6).once

    User.foo(1,2,3)
    User.new.foo(4,5,6)
  end

  def test_dequeue
    User.expects(:bar).with("a", "b", "c").twice
    User.bar("a", "b", "c")
    User.new.bar("a", "b", "c")
  end

  def test_early_returns
    Foo.expects(:bar).once
    Foo.early_return_if false
    Foo.early_return_if true
  end
end
