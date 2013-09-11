require 'resque'
require 'resque/tasks'

require 'q/methods/resque'

RESQUE_NAMESPACE = "q:redis:namespace"

# useful so we don't accidentally run other code
SETUP_RESQUE_NAMESPACE = Proc.new do
  Resque.redis.namespace = RESQUE_NAMESPACE
end


def start_resque
  @resque_stdout = StringIO.new
  Resque.inline  = false
  pid = Process.fork do
    SETUP_RESQUE_NAMESPACE.call
    # Object.const_set(:STDOUT, @resque_stdout)
    Resque.logger = Logger.new(@resque_stdout)
    Q::Methods::Resque::QueueTask.call
  end

  return pid, @resque_stdout
end
