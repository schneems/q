require 'test_helper'


class QTest < Test::Unit::TestCase

  def test_queue_lookup
    assert_equal Q::Methods::Resque,     Q.queue_lookup[:resque].call
    assert_equal Q::Methods::Sidekiq,    Q.queue_lookup[:sidekiq].call
    assert_equal Q::Methods::DelayedJob, Q.queue_lookup[:delayed_job].call
    assert_equal Q::Methods::Threaded,   Q.queue_lookup[:threaded].call
  end
end
