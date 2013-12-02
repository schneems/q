module Q
  module QueueTask
    def self.call(*args)
      Q.queue::QueueTask.call(args)
    end
  end
end

if defined?(Rake)
  task = Rake::Task.define_task("q:work" => :environment) do |t, args|
    Q::QueueTask.call(args)
  end
  task.add_description "Processes background work using the Q library"
end