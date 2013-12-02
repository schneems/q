module Q::Methods::DelayedJob
  include Q::Methods::Base
  class NotSetupError < StandardError
    def initialize
      msg =  "Delayed job not setup, please run:\n"
      msg << "  $ bundle exec rails generate delayed_job:active_record\n"
      msg << "  $ bundle exec rake db:migrate\n"
      super msg
    end
  end

  class QueueConfig
    def self.call
      ::Delayed::Job
    end
  end


  class QueueTask
    def self.call(*rake_args)
      Rake::Task["jobs:work"].invoke(rake_args)
    end
  end

  # class NewsletterJob < Struct.new(:text, :emails)
  #   def perform
  #     emails.each { |e| NewsletterMailer.deliver_text_to_email(text, e) }
  #   end
  # end
  class QueueBuild
    def self.call(options={}, &job)
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]

      raise NotSetupError unless ActiveRecord::Base.connection.table_exists? 'delayed_jobs'
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

  # Delayed::Job.enqueue NewsletterJob.new('lorem ipsum...', Customers.find(:all).collect(&:email))
  class QueueMethod
    def self.call(options = {})
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]
      queue_klass      = base.const_get(queue_klass_name)

      raise Q::DuplicateQueueMethodError.new(base, queue_name) if base.queue.respond_to?(queue_name)

      base.queue.define_singleton_method(queue_name) do |*args|
        ::Delayed::Job.enqueue(queue_klass, *args)
      end
    end
  end
end
