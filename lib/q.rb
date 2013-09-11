require 'proc_to_lambda'

module Q
  class Queue
  end
end

require 'q/version'
require 'q/helpers'
require 'q/errors'
require 'q/methods/base'
require 'q/methods'
require 'q/methods/threaded_in_memory_queue'

module Q
  extend Q::Helpers
  DEFAULT_QUEUE = ->{ @env = :threaded; Q::Methods::Threaded }
  FALSEY_HASH   = Hash.new(false)

  def self.queue
    @queue_method || DEFAULT_QUEUE.call
  end

  def self.setup(&block)
    yield self
  end

  def self.env
    name = queue.to_s.split("::").last
    @env ||= Q.underscore(name)
    OpenStruct.new(FALSEY_HASH.merge("#{@env}?" => true))
  end

  def self.reset_queue!
    @queue_method = nil
    @env          = nil
  end

  def self.queue=(queue)
    if queue.is_a?(Module)
      @queue_method = queue
    else
      @env          = queue
      @queue_method = module_from_queue_name(queue)
    end
  end

  def self.queue_config(&block)
    @config_class ||= queue::QueueConfig.call
    yield @config_class if block_given?
    @config_class
  end
end
