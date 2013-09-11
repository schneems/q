module Q
  module Methods
    include Q::Methods::Base

    class QueueConfig
      def self.call
        Q.queue::QueueConfig
      end
    end

    class QueueTask
      def self.call(*rake_args)
        Q.queue::QueueTask.call(rake_args)
      end
    end

    class QueueBuild
      def self.call(options={}, &job)
        Q.queue::QueueBuild.call(options, &job)
      end
    end

    class QueueMethod
      def self.call(options = {})
        Q.queue::QueueMethod.call(options)
      end
    end
  end
end
Q::Method = Q::Methods