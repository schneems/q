require 'test_helper'

class DelayedJobUser
  include Q::Methods::DelayedJob

  def self.bar; end

  queue(:foo) do |value|
    puts "Calling DelayedJobUser::Foo with value #{value}"
    DelayedJobUser.bar
  end
end

class DelayedJobTest < Test::Unit::TestCase

  def setup
    # @pid, @capture = start_delayed_job
  end

  def teardown
    # kill_process(@pid)
  end

  def output
    @output ||= ""
    @output << @capture.string
  end

  # def test_delayed_job_non_inline_works
  #   value = rand(1..99)
  #   DelayedJobUser.queue.foo(value)
  #   sleep 1
  #   assert_match "Calling DelayedJobUser::Foo with value #{value}", output
  # end
end
