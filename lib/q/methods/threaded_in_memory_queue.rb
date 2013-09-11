module Q::Methods::ThreadedInMemoryQueue
  def self.included(base)
    require 'threaded_in_memory_queue'
    at_exit do
      ThreadedInMemoryQueue.stop  unless ::ThreadedInMemoryQueue.stopped?
    end
    super base
  end

  include Q::Methods::Base

  class QueueConfig
    def self.call
      ::ThreadedInMemoryQueue
    end
  end

  class QueueTask
    def self.call(*rake_args)
      raise "Threaded In Memory Queue runs in web process, no need to start"
    end
  end

  class QueueBuild
    def self.call(options={}, &job)
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]

      raise Q::DuplicateQueueClassError.new(base, queue_klass_name) if Q.const_defined_on?(base, queue_klass_name)

      queue_klass = Class.new do
        def self.call(*args)
          @job.call(*args)
        end

        def self.job=(job)
          @job = job
        end
      end

      queue_klass.job = job
      base.const_set(queue_klass_name, queue_klass)
      return true
    end
  end

  class QueueMethod
    def self.call(options = {})
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]
      queue_klass      = base.const_get(queue_klass_name)

      raise Q::DuplicateQueueMethodError.new(base, queue_name) if base.queue.respond_to?(queue_name)
      base.queue.define_singleton_method(queue_name) do |*args|
        ::ThreadedInMemoryQueue.start unless ::ThreadedInMemoryQueue.started?
        ::ThreadedInMemoryQueue.enqueue(queue_klass, *args)
      end
    end
  end
end

# alias
Q::Methods::Threaded = Q::Methods::ThreadedInMemoryQueue
