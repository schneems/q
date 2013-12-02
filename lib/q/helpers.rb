module Q
  module Helpers
    def camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string = string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$2.capitalize}" }.gsub('/', '::')
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
  end
end
