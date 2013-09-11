require 'test_helper'

module FakeQueueKlass
  include Q::Methods::Base

  class QueueMethod; end
  class QueueBuild;  end
  class QueueTask;   end
  class QueueConfig; end
end

class FakeUserKlass
  include FakeQueueKlass
end

module FakeIncludesKlass
  def self.bar(val)
  end

  def self.included(klass)
    self.bar
    super
  end

  include FakeQueueKlass
end

class QMethodsBaseTest < Test::Unit::TestCase

  def test_includes_propper_things
    assert_includes   FakeQueueKlass,    Q::Methods::Base
    assert_respond_to FakeUserKlass,     :queue
    assert_respond_to FakeUserKlass.new, :queue
  end

  def test_queue_klass
    assert_equal FakeQueueKlass, FakeUserKlass.class_variable_get("@@_q_klass")
  end

  def test_includes_gets_called
    FakeIncludesKlass.expects(:bar).once
    Class.new do
      include FakeIncludesKlass
    end
    assert_includes   FakeIncludesKlass,    Q::Methods::Base
  end

  def test_raises_error_missing_klasses
    # assert no raise
    foo = Module.new do
      include Q::Methods::Base
    end
    foo.const_set(:QueueMethod, "")
    foo.const_set(:QueueBuild,  "")
    foo.const_set(:QueueTask,   "")
    foo.const_set(:QueueConfig, "")
    Class.new { include foo }

    error = assert_raise(Q::MissingClassError) do
      foo = Module.new do
        include Q::Methods::Base
      end
      foo.const_set(:QueueBuild,  "")
      foo.const_set(:QueueTask,   "")
      foo.const_set(:QueueConfig, "")
      Class.new { include foo }
    end
    assert_match "QueueMethod", error.message

    error = assert_raise(Q::MissingClassError) do
      foo = Module.new do
        include Q::Methods::Base
      end
      foo.const_set(:QueueMethod, "")
      foo.const_set(:QueueTask,   "")
      foo.const_set(:QueueConfig, "")
      Class.new { include foo }
    end
    assert_match "QueueBuild", error.message

    error = assert_raise(Q::MissingClassError) do
      foo = Module.new do
        include Q::Methods::Base
      end
      foo.const_set(:QueueMethod, "")
      foo.const_set(:QueueBuild,  "")
      foo.const_set(:QueueConfig, "")
      Class.new { include foo }
    end
    assert_match "QueueTask", error.message

    error = assert_raise(Q::MissingClassError) do
      foo = Module.new do
        include Q::Methods::Base
      end
      foo.const_set(:QueueMethod, "")
      foo.const_set(:QueueBuild,  "")
      foo.const_set(:QueueTask,   "")
      Class.new { include foo }
    end
    assert_match "QueueConfig", error.message
  end
end
