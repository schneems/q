module Q::Methods::Resque
  include Q::Methods::Base

  class Config
    def self.call
      ::Resque
    end
  end

  class Task
    def self.call(*rake_args)

    end
  end

  class BuildQueue
    def self.call(options={}, &job)
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]

      raise DuplicateQueueClassError.new(base, queue_klass_name) if base.const_defined?(queue_klass_name)

      queue_klass = Class.new do
        def self.perform(*args)
          @job.call(*args)
        end

        def self.job=(job)
          @job = job
        end

        def self.queue=(queue)
          @queue = queue
        end
      end

      queue_klass.job   = block
      queue_klass.queue = queue_name

      queue_klass       = base.const_set(queue_klass_name, queue_klass)
      return true
    end
  end

  class BuildMethod
    def self.call(options = {})
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]
      queue_klass      = base.const_get(queue_klass_name)

      raise Q::DuplicateQueueMethodError.new(base, queue_name) if base.queue.respond_to?(queue_name)

      base.queue.define_singleton_method(queue_name) do |*args|
        ::Resque.enqueue(queue_klass, *args)
      end
    end
  end
end
