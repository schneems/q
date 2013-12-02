require 'q'
require 'sidekiq'
require 'q/methods/sidekiq'

SIDEKIQ_NAMESPACE = "q:sidekiq:namespace"

SETUP_SIDEKIQ_NAMESPACE = Proc.new do
  Sidekiq.configure_client do |config|
    config.redis = { :namespace => SIDEKIQ_NAMESPACE }
  end
end

def start_sidekiq
  stdout = StringIO.new
  Q::Methods::Sidekiq::QueueConfig.call.inline = false
  pid = Process.fork do
    SETUP_SIDEKIQ_NAMESPACE.call
    # Object.const_set(:STDOUT, stdout
    Sidekiq.logger = Logger.new(stdout)
    Q::Methods::Sidekiq::QueueTask.call
  end

  return pid, stdout
end


SETUP_SIDEKIQ_NAMESPACE.call

class SidekiqUser
  include Q::Methods::Sidekiq

  def self.bar; end

  queue(:foo) do |value|
    Sidekiq.logger.info "Calling SidekiqUser::Foo with value #{value}"
    SidekiqUser.bar
  end
end
