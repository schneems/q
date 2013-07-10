module Q
  module Methods
    include Q::Methods::Base

    class Task
      def call(*rake_args)
        Q.global_queue::Task.call(rake_args)
      end
    end

    class BuildQueue
      def call(options={}, &job)
        Q.global_queue::BuildQueue.call(options, &job)
      end
    end

    class BuildMethod
      def call(options = {})
        Q.global_queue::BuildMethod.call(options)
      end
    end
  end
end
Q::Method = Q::Methods