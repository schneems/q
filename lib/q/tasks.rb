module Q
  module QueueTask
    def self.call(*args)
      Q.global_queue::Task.call(args)
    end
  end
end

namespace :q do
  task :work => :environment do |t, args|
    Q::QueueTask.call(args)
  end
end
