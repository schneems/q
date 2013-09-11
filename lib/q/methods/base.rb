module Q
  module Methods
    module Base
      def self.included(base)
        base.const_set("Queue", Class.new(::Q::Queue)) unless base.const_get("Queue") != ::Queue

        included = base.method(:included) if base.respond_to?(:included)
        base.define_singleton_method(:included) do |target|
          included.call(target) unless included.nil?

          raise Q::MissingClassError.new(base, :QueueMethod) unless Q.const_defined_on?(base, :QueueMethod)
          raise Q::MissingClassError.new(base, :QueueBuild)  unless Q.const_defined_on?(base, :QueueBuild)
          raise Q::MissingClassError.new(base, :QueueTask)   unless Q.const_defined_on?(base, :QueueTask)
          raise Q::MissingClassError.new(base, :QueueConfig) unless Q.const_defined_on?(base, :QueueConfig)

          target.extend(ClassMethods)
          target.send(:include, InstanceMethods)

          target.class_variable_set(:@@_q_klass, base)            unless target.class_variable_defined?(:@@_q_klass)
          target.class_variable_set(:@@_q_queue, base::Queue.new) unless target.class_variable_defined?(:@@_q_queue)
        end
      end

      module InstanceMethods
        def queue
          raise Q::InstanceQueueDefinitionError.new(self) if block_given?
          self.class.queue
        end
      end

      module ClassMethods
        def queue(*args, &block)
          queue = self.class_variable_get(:@@_q_queue)

          return queue unless block_given?

          queue_name   = args.shift
          job          = Q.proc_to_lambda(&block)

          raise "first argument #{queue_name.inspect} must be a symbol to define a queue" unless queue_name.is_a?(Symbol)

          options = { base:             self,
                      queue_name:       queue_name,
                      queue_klass_name: Q.camelize(queue_name) }

          queue_klass = self.class_variable_get(:@@_q_klass)
          queue_klass::QueueBuild.call(options, &job)
          queue_klass::QueueMethod.call(options)
        end
      end
    end
  end
end
