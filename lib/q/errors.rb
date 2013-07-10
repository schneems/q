module Q
  class StandardError < ::StandardError; end

  class MissingClassError < StandardError
    def initialize(base, missing_klass)
      msg = "#{base} must define '#{missing_klass}' class with a call method"
      super(msg)
    end
  end

  class DuplicateQueueClassError < StandardError
    def initialize(base, duplicate_klass)
      msg = "Cannot create queue class: '#{duplicate_klass}' because #{duplicate_klass} is already defined on #{base}"
      super(msg)
    end
  end

  class DuplicateQueueMethodError < StandardError
    def initialize(base, method)
      msg = "Cannot create queue method: '#{method}'. Method already exists on #{base}.queue, cannot overwrite"
      msg << "Originally defined at #{base.queue.method(method).source_location}"
      super(msg)
    end
  end
end
