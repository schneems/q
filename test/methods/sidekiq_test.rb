require 'test_helper'
require 'q/methods/resque'


class SidekiqTest < Test::Unit::TestCase

  def setup
    @pid, @capture = start_sidekiq
  end

  def teardown
    kill_process(@pid)
  end

  def output
    @output ||= ""
    @output << @capture.string
  end

  def test_sidekiq_non_inline_works
    value = rand(1..99)
    SidekiqUser.queue.foo(value)
    sleep 1
    assert_match output, "Calling SidekiqUser::Foo with value #{value}"
  end

  # def test_sidekiq_with_inline_works
  #   value = rand(1..99)
  #   Q.queue_config.inline = true

  #   SidekiqUser.queue.foo(value)
  #   sleep 1
  #   assert_match "Calling SidekiqUser::Foo with value #{value}", output
  # ensure
  #   Q.queue_config.inline = false
  # end
end
