require 'threaded_in_memory_queue'

ThreadedInMemoryQueue.configure do |config|
  config.size = 2
end
