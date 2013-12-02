require 'delayed_job_active_record'

require 'q/methods/delayed_job'

require 'delayed_job'


ESTABLISH_ACTIVERECORD = Proc.new do
  ActiveRecord::Base.establish_connection adapter: "sqlite3", database: "test/db/test.db"

  ActiveRecord::Schema.define do
    create_table :delayed_jobs, :force => true do |table|
      table.integer  :priority, :default => 0
      table.integer  :attempts, :default => 0
      table.text     :handler
      table.text     :last_error
      table.datetime :run_at
      table.datetime :locked_at
      table.datetime :failed_at
      table.string   :locked_by
      table.string   :queue
      table.timestamps
    end
  end
end

ESTABLISH_ACTIVERECORD.call

def start_delayed_job
  stdout = StringIO.new
  pid = Process.fork do
    ESTABLISH_ACTIVERECORD.call
    Delayed::Worker.logger = Logger.new(stdout)
    Q::Methods::DelayedJob::QueueTask.call
  end

  return pid, stdout
end


namespace :jobs do

  desc "Clear the delayed_job queue."
  task :clear do
    Delayed::Job.delete_all
  end

  desc "Start a delayed_job worker."
  task :work => :environment_options do
    Delayed::Worker.new(@worker_options).start
  end

  desc "Start a delayed_job worker and exit when all available jobs are complete."
  task :workoff => :environment_options do
    Delayed::Worker.new(@worker_options.merge({:exit_on_complete => true})).start
  end

  task :environment_options do
    @worker_options = {
      :min_priority => ENV['MIN_PRIORITY'],
      :max_priority => ENV['MAX_PRIORITY'],
      :queues => (ENV['QUEUES'] || ENV['QUEUE'] || '').split(','),
      :quiet => false
    }
  end
end
