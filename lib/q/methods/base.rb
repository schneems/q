module Q
  module Methods
    module Base
      def self.included(base)
        base.const_set("Queue", Class.new)

        included = base.method(:included) if base.respond_to?(:included)
        base.define_singleton_method(:included) do |target|
          included.call(target) unless included.nil?
          raise Q::MissingClassError.new(base, :QueueMethod) unless base.const_defined?(:QueueMethod)
          raise Q::MissingClassError.new(base, :QueueBuild)  unless base.const_defined?(:QueueBuild)
          raise Q::MissingClassError.new(base, :QueueTask)   unless base.const_defined?(:QueueTask)
          raise Q::MissingClassError.new(base, :QueueConfig) unless base.const_defined?(:QueueConfig)

          target.extend(ClassMethods)
          target.send(:include, InstanceMethods)

          # Not totally threadsafe
          target.class_variable_set(:@@_q_klass, base)            unless target.class_variable_defined?(:@@_q_klass)
          target.class_variable_set(:@@_q_queue, base::Queue.new) unless target.class_variable_defined?(:@@_q_queue)
        end
      end

      module InstanceMethods
        def queue(*args, &block)
          raise "instance cannot accept block" if block
          self.class.queue(*args)
        end
      end

      module ClassMethods
        def queue(*args, &block)
          queue = self.class_variable_get(:@@_q_queue)

          return queue unless block_given?

          queue_name   = args.shift
          queue_klass  = self.class_variable_get(:@@_q_klass)
          job          = Q.proc_to_lambda(&block)

          raise "first argument #{queue_name.inspect} must be a symbol to define a queue" unless queue_name.is_a?(Symbol)

          options = { base:             self,
                      queue_name:       queue_name,
                      queue_klass_name: Q.camelize(queue_name) }

          queue_klass::QueueBuild.call(options, &job) # Not totally threadsafe
          queue_klass::QueueMethod.call(options)        # Not totally threadsafe
        end
      end
    end
  end
end
