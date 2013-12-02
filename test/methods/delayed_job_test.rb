require 'test_helper'

class DelayedJobUser
  include Q::Methods::DelayedJob

  def self.bar; end

  queue(:foo) do |value|
    puts "Calling ResqueUser::Foo with value #{value}"
    DelayedJobUser.bar
  end
end

class DelayedJobTest < Test::Unit::TestCase

  def setup

  end

  def teardown
    kill_process(@pid)
  end

  def output
    @output ||= ""
    @output << @capture.string
  end

  def test_delayed_job_non_inline_workss
  end
end
