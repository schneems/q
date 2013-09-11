module Q
  module Helpers
    def camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$2.capitalize}" }.gsub('/', '::')
      string
    end

    def underscore(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { "#{$&.downcase}_" }
      string = string.gsub(/^_/, '')
      string
    end

    def const_defined_on?(on, const)
      on.constants.include?(const.to_sym)
    end

    def proc_to_lambda(block = nil, &proc)
      ::ProcToLambda.to_lambda(block || proc)
    end

    def module_from_klass_name(name)
      unless defined?(Q::Methods.const_get(name))
        require "q/methods/#{name}"
      end
      return Q::Methods.const_get(name)
    rescue LoadError => e
      raise LoadError, "Could not find queue: #{name}, expected to be defined in q/methods/#{name}\n" + e.message
    rescue NameError => e
      raise NameError, "Could not load queue: #{name}, expected to be defined in q/methods/#{name}\n" + e.message
    end

    def module_from_queue_name(queue_name)
      module_from_klass_name(camelize(queue_name))
    end
  end
end
