module ResqueDef
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def resque_def(resque_name, &block)
      # convert resque_name like :delay_send_issues to DelaySendIssues for klass name
      resque_klass_name = resque_name.to_s.capitalize.gsub(/_\S/) {|m| m.upcase}.gsub('_', '')


      # convert proc to lambda :(
      obj = Object.new
      obj.define_singleton_method(:_, &block)
      block = obj.method(:_).to_proc

      # create the resque klass
      resque_klass = Class.new do
        @queue = resque_name

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
      resque_klass.job   = block
      resque_klass.queue = resque_name

      # assign the object to a constant we can look up later
      resque_klass = self.const_set(resque_klass_name, resque_klass)

      # create the class method to enqueue the resque job
      define_singleton_method(resque_name) do |*args|
        Resque.enqueue(resque_klass, *args)
      end

      # helper instance method, calls the class method
      define_method(resque_name) do |*args|
        self.class.send(resque_name, *args)
      end
    end
  end
end

require 'resque_def/version'