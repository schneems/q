require 'resque'
require 'resque/tasks'

require 'q/methods/resque'

RESQUE_NAMESPACE = "q:redis:namespace"

# useful so we don't accidentally run other code
SETUP_RESQUE_NAMESPACE = Proc.new do
  Resque.redis.namespace = RESQUE_NAMESPACE
end

SETUP_RESQUE_NAMESPACE.call

def start_resque
  stdout = StringIO.new
  Resque.inline  = false
  pid = Process.fork do
    SETUP_RESQUE_NAMESPACE.call
    Resque.logger = Logger.new(stdout)
    Q::Methods::Resque::QueueTask.call
  end

  return pid, stdout
end
