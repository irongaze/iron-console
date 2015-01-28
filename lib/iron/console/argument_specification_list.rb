class Console

  # Maintains an array of argument specifications, used in DSL-like builder mode to specify
  # arguments for a script or argument set.
  class ArgumentSpecificationList < Array

    # Set up our builder-ish handlers
    [:wildcard, :bool, :const, :string, :int, :float, :email, :ip_address].each do |arg_type|
      self.class_eval <<-eos
        def #{arg_type}(*args, &block)
          add_spec('#{arg_type}', *args, &block)
        end
      eos
    end
    
    def initialize(extra_options = {})
      @extra_options = extra_options
    end
    
    # Internal construction helper that builds a new argument definition, yields it
    # for customizing sub-arguments (eg sets), and adds it to the list.  Returns the new
    # spec.
    def add_spec(type, name, desc = nil, params = {})
      # Ensure required params are set
      raise SpecificationError.new("Invalid #{type} specification - name must be a string") unless name.is_a?(String)
      
      # Bump over options if needed (ie no description provided)
      if desc.is_a?(Hash)
        params = desc
        desc = nil
      end
      
      # Add in extra options if needed
      params.merge!(@extra_options)
      
      # Create a new instance of the given argument spec type
      klass = type.to_s.split(/[_\-]/).collect{|s| s.capitalize}.join
      klass = "Console::#{klass}Specification".constantize
      item = klass.new(name, desc, params)
      
      # Add it to the list!
      self << item

      # All set here...
      item
    end
  end

end
