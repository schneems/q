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
require 'q/tasks'

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

  def self.module_from_klass_name(name)
    unless defined?(Q::Methods.const_get(name))
      require "q/methods/#{name}"
    end
    return Q::Methods.const_get(name)
  rescue LoadError => e
    raise LoadError, "Could not find queue: #{name}, expected to be defined in q/methods/#{name}\n" + e.message
  rescue NameError => e
    raise NameError, "Could not load queue: #{name}, expected to be defined in q/methods/#{name}\n" + e.message
  end

  def self.module_from_queue_name(queue_name)
    module_from_klass_name(camelize(queue_name))
  end

  def self.queue_lookup
    @queue_lookup ||= Hash.new do |hash, key|
      hash[key] = -> {
        require "q/methods/#{key}"
        const = Q.camelize(key)
        ::Q::Methods.const_get(const)
      }
    end
    @queue_lookup
  end

  def self.queue=(queue)
    if queue.is_a?(Module)
      @queue_method = queue
    else
      @env = queue
      @queue_method = queue_lookup[queue].call
    end
  end

  def self.queue_config(&block)
    @config_class ||= queue::QueueConfig.call
    yield @config_class if block_given?
    @config_class
  end
end

require 'q/methods/threaded_in_memory_queue'
