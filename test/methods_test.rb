require 'test_helper'


f = Proc.new do |queue_type|


  class MtPoro
    include Q::Methods

    queue(:quux) do

    end
  end
end

class MethodsTest < Test::Unit::TestCase

  def teardown
    Q.reset_queue!
  end

  def test_propper_switching

    Q.queue = :threaded

    assert_equal Q::Methods::Threaded, Q.queue
    Q::Methods::Threaded::QueueBuild.expects(:call).once
    Q::Methods::Threaded::QueueMethod.expects(:call).once

    Class.new do
      include Q::Methods
      queue(:quux) {}
    end

    Q.queue = :resque

    assert_equal Q::Methods::Resque, Q.queue
    Q::Methods::Resque::QueueBuild.expects(:call).once
    Q::Methods::Resque::QueueMethod.expects(:call).once

    Class.new do
      include Q::Methods
      queue(:quux){}
    end
  end

  def test_env
    Q.queue = :threaded
    assert Q.env.threaded?
    refute Q.env.resque?

    Q.reset_queue!

    assert Q.env.threaded?
    refute Q.env.resque?

    Q.queue = :resque

    refute Q.env.threaded
    assert Q.env.resque?
  end

end