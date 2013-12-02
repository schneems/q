require 'test_helper'

SETUP_RESQUE_NAMESPACE.call

class ResqueUser
  include Q::Methods::Resque

  def self.bar; end

  queue(:foo) do |value|
    Resque.logger.info "Calling ResqueUser::Foo with value #{value}"
    ResqueUser.bar
  end
end

class ResqueTest < Test::Unit::TestCase

  def setup
    @pid, @capture = start_resque
  end

  def teardown
    kill_process(@pid)
  end

  def output
    @output ||= ""
    @output << @capture.string
  end

  def test_resque_non_inline_works
    value = rand(1..99)
    ResqueUser.queue.foo(value)
    sleep 5
    assert_match "Calling ResqueUser::Foo with value #{value}", output
  end
end
