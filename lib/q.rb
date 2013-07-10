module Q; end

require 'proc_to_lambda'
require 'threaded_in_memory_queue'

require 'q/version'
require 'q/helpers'
require 'q/errors'
require 'q/methods/base'
require 'q/methods'
require 'q/methods/threaded_in_memory_queue'

module Q
  extend Q::Helpers
  DEFAULT_QUEUE = Q::Methods::Threaded

  def self.global_queue
    @queue_method || DEFAULT_QUEUE
  end

  def self.setup(&block)
    yield self
  end

  def self.global_queue=(queue)
    @queue_method = if queue.is_a?(Module)
      queue
    else
      queue = module_from_queue_name(queue)
    end
  end

  def self.queue_config(&block)
    @config_class ||= global_queue::QueueConfig.call
    yield @config_class if block_given?
    @config_class
  end
end
