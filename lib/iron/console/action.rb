require 'iron/console/argument_specification_list'

class Console

  # Implements the base class for console actions, which are classes that manage the definition
  # of a set of arguments, and the invocation of whatever action those arguments represent.  Each
  # console application has one or more actions defined.  The action taken is determined by parsing
  # the command line, then finding the first action whose required arguments match that input.
  class Action

    # Valid option matching modes
    # 
    # :any - zero or more matches
    # :all - every option must have a value (includes options with defaults)
    # :one - exactly one option must have a value (includes options with defaults)
    OPTION_MODES = [:any, :all, :one]
    
    # Arguments passed on command line, parsed and assigned as hash to their argument definition keys
    attr_reader :args, :options
    
    # When a subclass is defined, add it to the app's list of potential actions to match against
    def self.inherited(subclass)
      Console.app.add_action(subclass)
    end
    
    # Converts our class name to a key, eg 'SomeModule::FooBarAction' => :foo_bar
    def self.key
      self.name.gsub(/Action$/, '').gsub(/^.*::/, '').gsub(/([a-z])([A-Z])/,'\1_\2').downcase.to_sym
    end
    
    # Set this action as a hidden, undocumented action, useful for help or other types of catch-all behaviors
    def self.nodoc!
      @nodoc = true
    end
    
    # When true, won't show in the --help output for the app
    def self.nodoc?
      @nodoc === true
    end
    
    # Call in derived class definitions to specify what arguments the derived action accepts
    def self.args(&block) # :yields: argument_builder
      if block || @arg_list.nil?
        @arg_list = ArgumentSpecificationList.new
        DslProxy.exec(@arg_list, &block) if block
      end
      @arg_list
    end

    # Call in derived class definitions to specify what arguments the derived action accepts
    def self.options(match = :any, &block) # :yields: option_builder
      if block || @option_list.nil?
        # Save our option matching requirements
        raise ArgumentError.new("Unknown options match mode - :#{match} - must be one of #{OPTION_MODES.collect{|m| ":#{m}"}.join(', ')}") unless OPTION_MODES.include?(match)
        @option_match = match
        
        # Create a new list of option specs, and pass to block for customization
        @option_list = ArgumentSpecificationList.new(:as_option => true)
        DslProxy.exec(@option_list, &block) if block
        
        # Mark all option specs as being options...
        @option_list.each do |spec|
          spec.option = true
        end
      end
      @option_list
    end

    # Set a description of this action that will be used in the help system
    def self.desc(text = nil)
      @desc = text unless text.blank?
      @desc
    end

    # Called with command-line parsed arguments array in string (non-interpreted) form, and
    # options hash in name => string value form.
    #
    # Return an instance of our class filled with parsed values if our args and options matches,
    # ready to invoke, or nil if cannot match command line arguments.
    def self.match(arg_strings, options_hash)
      # Match our arguments
      arg_vals = match_args_with_branching(arg_strings)
      return nil if arg_vals.nil?

      # Set up for option parsing
      options_hash = options_hash.dup
      option_vals = {}
      
      # Use our option set to match option values/flags
      self.options.each do |option|
        return nil unless option.match_as_option(options_hash, option_vals)
      end
      
      # Make sure we matched all passed options
      return nil unless options_hash.empty?

      # Check to see if we have the right number of options
      # See if we made it work
      option_count = option_vals.size
      case @option_match
      when :one then
        return nil unless option_count == 1
      when :any then
        # Always fine here
      when :all then
        return nil unless option_count == @option_list.size
      end
      
      # We have a winner, return a new instance with the parsed argument values
      return self.new(arg_vals, option_vals)
    end

    # We run a branching simulation to match our arguments, to allow optional values
    # in any position.
    def self.match_args_with_branching(arg_strings)
      # Cases will consist of 
      branches = [{:vals => {}, :remaining => arg_strings.dup}]
      
      self.args.each do |arg|
        # Set up new set of branches
        new_branches = []
        
        # Run each existing branch, test it to see if we can match against it, and add zero
        # or more branches back to the new_branches set
        branches.each do |branch|
          vals = branch[:vals]
          remaining = branch[:remaining]

          # Test to see if we can match this value, and extend this branch if so.  If not,
          # simply prune the branch by not re-adding it.
          new_vals = vals.dup
          new_remaining = remaining.dup
          if arg.match_as_arg(new_remaining, new_vals)
            new_branches << {:vals => new_vals, :remaining => new_remaining}
          end

          # If arg is optional, we add a branch where the val is skipped
          if arg.optional?
            # Duplicate our vals and remaining array for new branch
            new_vals = vals.dup
            new_remaining = remaining.dup
            # Do the match to pull in default values
            if arg.match_as_arg([], new_vals)
              # Add the branch
              new_branches << {:vals => new_vals, :remaining => new_remaining}
            end
          end

        end
        
        # Use our new set of branches
        branches = new_branches
      end
      
      # Prune branches that have remaining values left un-matched
      branches.select! {|b| b[:remaining].empty? }
      
      # Return a hash of arg key => vals on success, or nil on failure
      branches.empty? ? nil : branches.first[:vals]
    end
    
    # Instantiate and run this action with the given arguments and options.  Arguments and
    # options should be in '<key>' => <parsed value> form, (ie 'flag' => true not 'flag' => 'yes')
    def self.invoke(args = {}, options = {})
      self.new(args, options).invoke
    end

    # Display name for this action (converts eg Foo::RunCommandAction to "Run Command")
    def self.display_name
      self.name.gsub(/Action$/, '').gsub(/^.*::/, '').gsub(/([a-z])([A-Z])/,'\1 \2')
    end
    
    # Output our usage
    def self.display_usage
      Console::HelpAction.invoke({:action => self.key})
      true
    end

    def display_usage
      self.class.display_usage
    end
    
    # Call with a hash of arg key => arg, and option key => option
    def initialize(args = {}, options = {})
      @args = args
      @options = options
    end

    # Override to do stuff
    def invoke
      Console.p "TODO: Implement #{self.class.name}.invoke"
    end

    # Render our args and so forth out as help
    def self.to_help
      Console.out do
        indent do

          # Our usage
          br
          p 'Usage:'
          indent do
            write Console.command_line.base + ' '
            unless options.empty?
              case @option_match
              when :any then
                write '[options...] '
              when :all then
                write '<required options> '
              when :one then
                write '<single option> '
              end
            end
            write args.collect{|arg| arg.to_param}.join(' ')
            end_line
          end

          # Arguments
          unless args.empty?
            br
            p 'Arguments:'
            indent do
              usage = args.collect {|arg| arg.to_usage}
              usage.compact!
              usage.each do |name, desc|
                write name
                write ' '
                write desc
                end_line
              end
            end
          end

          # Option details
          unless options.empty?
            br
            case @option_match
            when :any, :one then
              p 'Available Options:'
            when :all then
              p 'Required Options:'
            end
            indent do
              usage = options.collect {|opt| opt.to_usage}
              usage.compact!
              usage.each do |name, desc|
                write name
                write ' '
                write desc
                end_line
              end
            end
          end

          # Description
          unless desc.blank?
            br
            p 'Description:'
            indent do
              p desc
            end
          end

          br
        end
      end
    end
    
  end
end
