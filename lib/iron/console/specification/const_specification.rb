require 'iron/console/specification/string_specification'

class Console
  
  # Accepts a constant value, useful in requiring a given string in a given position to disambiguate possible actions in
  # multi-action scripts, returned in args as a symbol
  class ConstSpecification < StringSpecification
    def initialize(name, desc = nil, params = {})
      super
      @options = [name.to_dashcase] if @options.nil? || @options.empty?
    end

    def parse(val)
      val.to_dashcase.to_sym
    end
  end
  
end
