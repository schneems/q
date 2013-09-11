module Q::Methods::Sidekiq
  include Q::Methods::Base

  class QueueConfig
    def self.call
      setup_inline!
      ::Sidekiq
    end

    def self.setup_inline!
      return if @regular_client
      @regular_client = ::Sidekiq::Client

      ::Sidekiq.define_singleton_method(:inline) do
        ::Sidekiq::Client == @inline_client
      end

      ::Sidekiq.define_singleton_method(:inline=) do |val|
        @regular_client ||= ::Sidekiq::Client

        if val
          require 'sidekiq/testing/inline'
          @inline_client  ||= ::Sidekiq::Client
          Sidekiq.const_set("Client", @inline_client)
        else
          Sidekiq.const_set("Client", @regular_client)
        end
      end
    end
  end

  class QueueTask

    # -c, --concurrency INT            processor threads to use
    # -d, --daemon                     Daemonize process
    # -e, --environment ENV            Application environment
    # -g, --tag TAG                    Process tag for procline
    # -i, --index INT                  unique process index on this machine
    # -p, --profile                    Profile all code run by Sidekiq
    # -q, --queue QUEUE[,WEIGHT]...    Queues to process with optional weights
    # -r, --require [PATH|DIR]         Location of Rails application with workers or file to require
    # -t, --timeout NUM                Shutdown timeout
    # -v, --verbose                    Print more verbose output
    # -C, --config PATH                path to YAML config file
    # -L, --logfile PATH               path to writable logfile
    # -P, --pidfile PATH               path to pidfile
    # -V, --version                    Print version and exit
    # -h, --help                       Show help
    def self.call(*args)
      setup!
      cmd = "bundle exec sidekiq "
      cmd << ENV["QUEUE"]   if ENV["QUEUE"]
      cmd << args.join(" ") if args.any?
      puts cmd.inspect
      exec cmd
    end

    def self.setup!
      return unless database_url = ENV['DATABASE_URL']
      Sidekiq.configure_server do |config|
        ENV['DATABASE_URL'] = "#{database_url}?pool=25"
        ActiveRecord::Base.establish_connection
      end
    end
  end

  # example
  # class SinatraWorker
  #   include Sidekiq::Worker
  #
  #   def perform(msg="lulz you forgot a msg!")
  #     $redis.lpush("sinkiq-example-messages", msg)
  #   end
  # end
  class QueueBuild
    def self.call(options={}, &job)
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]

      raise Q::DuplicateQueueClassError.new(base, queue_klass_name) if Q.const_defined_on?(base, queue_klass_name)

      queue_klass = Class.new do
        include ::Sidekiq::Worker

        def perform(*args)
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

  # Example
  # SinatraWorker.perform_async params[:msg]
  class QueueMethod
    def self.call(options = {})
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]
      queue_klass      = base.const_get(queue_klass_name)

      raise Q::DuplicateQueueMethodError.new(base, queue_name) if base.queue.respond_to?(queue_name)

      base.queue.define_singleton_method(queue_name) do |*args|
        queue_klass.perform_async(*args)
      end
    end
  end
end
