class Console

  # Base class for our various argument spec classes.  Provides common functionality
  # for all argument specs, such as matching support.
  class ArgumentSpecification
    
    attr_accessor :name, :desc, :required, :default
    attr_accessor :option, :flag

    def initialize(name, desc = nil, params = {})
      # Defaults
      @option = params[:as_option] === true

      # Store out basics
      @name = name
      @desc = desc
      @params = params

      # Extract settings
      @flag = params[:flag]
      if option?
        @required = (params[:required] === true || params[:optional] === false)
      else
        @required = !(params[:required] === false || params[:optional] === true)
      end
      @default = params[:default]
    end

    # Take in the remaining arguments to match and the list of "final" params,
    # and add ourselves to the latter if we match the former.
    def match_as_arg(in_array, out_hash)
      #Console.p("Matching arg on #{to_arg_name} == [#{in_array.first}]")

      # Take the value in if possible, re-add it to the unmatched args if not
      if parse_and_save(out_hash, in_array.first)
        in_array.shift
        return true
      else
        return false
      end
    end

    # Take in the remaining arguments to match and the list of "final" params,
    # and add ourselves to the latter if we match the former.
    def match_as_option(in_hash, out_hash)
      #Console.p("Matching options on #{to_flags.join(',')} in #{in_hash.inspect}")

      # See if we've been set explicitly
      to_flags.each do |flag|
        if in_hash.keys.include?(flag)
          val = in_hash.delete(flag)
          return parse_and_save(out_hash, val)
        end
      end
      
      # If not, see if we have a default
      if has_default?
        # Use our default
        out_hash[to_sym] = default
        return true
      else
        # Fail unless we're optional
        return optional?
      end
    end

    # Parse a given string (aka raw) value, adding it to the results hash and returning true
    # if successful, returning false otherwise.
    def parse_and_save(results, val)
      # Check to see if we can match
      parseable = !val.nil? && match?(val)
      if parseable
        # Have a valid value, save it to the hash and return success
        #Console.p("'#{val}' parseable, saving as :#{to_sym}")
        results[to_sym] = parse(val)
        return true
        
      elsif option?
        # When we're an option and are passed a value, that value must be valid
        #Console.p("'#{val}' unparseable, failing!")
        return false
        
      else
        # Must be an argument, see if we have a default or if we're not required
        if has_default?
          # Use our default
          results[to_sym] = default
          return true
        else
          # Fail unless we're optional
          #Console.p("'#{val}' unparseable, #{optional? ? 'but optional' : 'failing!'}")
          return optional?
        end
      end
    end

    # When true, may be absent and still match
    def optional?
      !required? || has_default?
    end
    
    # When true, must be present to match
    def required?
      @required === true
    end

    # When true, has a default value
    def has_default?
      !@default.nil?
    end

    # When true, is an option argument
    def option?
      @option === true
    end    

    # Override to limit acceptable value strings
    def match?(val)
      false
    end

    # Override to convert incoming string into value
    def parse(str)
      str
    end

    # Return an array of valid flags for this argument
    def to_flags(display = false)
      if display
        flags = ["--" + @name.to_dashcase]
        flags << "-#{@flag}" if @flag
      else
        flags = [@name.to_dashcase]
        flags << @flag if @flag
      end        
      flags
    end

    # Convert to symbol for result hash
    def to_sym
      @name.to_dashcase.gsub(/-/, '_').to_sym
    end

    # Convert to key for display to user in help
    def to_arg_name
      @name.downcase
    end

    # Convert to key for display to user in help
    def to_option_name
      to_flags(true).join("\n")
    end
    
    # Return [name, desc] for display in help
    def to_usage
      name = option? ? to_option_name : to_arg_name
      desc = @desc.blank? ? '(no description)' : @desc
      [name, desc]
    end

    # How to display this argument in the usage line of the help
    def to_param
      optional? ? "[<#{to_arg_name}>]" : "<#{to_arg_name}>"
    end
    
    # Convert to key for display to user in help
    def to_key
      to_arg_name
    end
  end

end

# Require all specification sub-types
dir = File.join(File.expand_path(File.dirname(__FILE__)), 'specification')
Dir.glob(File.join(dir, '*.rb')).each do |name|
  require name
end

