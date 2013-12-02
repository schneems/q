module Q::Methods::Resque
  include Q::Methods::Base

  class QueueConfig
    def self.call
      ::Resque
    end
  end

  class QueueTask
    def self.call(*rake_args)
      Resque.logger.level ||= Integer(ENV['VVERBOSE'] || 1)
      ENV['QUEUE']        ||= "*"
      ENV['VERBOSE']      ||= "1"
      ENV['TERM_CHILD']   ||= '1'
      ENV['VVERBOSE']     = nil
      define_setup!
      Rake::Task["resque:work"].invoke(rake_args)
    end

    def self.define_setup!
      return true unless Rake::Task.task_defined?("resque:setup")
      Rake::Task.define_task("resque:setup" => :environment) do
        Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection } if defined?(ActiveRecord)
      end
    end
  end

  class QueueBuild
    def self.call(options={}, &job)
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]

      raise Q::DuplicateQueueClassError.new(base, queue_klass_name) if Q.const_defined_on?(base, queue_klass_name)

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

      queue_klass.job   = job
      queue_klass.queue = queue_name

      queue_klass       = base.const_set(queue_klass_name, queue_klass)
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
        ::Resque.enqueue(queue_klass, *args)
      end
    end
  end
end
