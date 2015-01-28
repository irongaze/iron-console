require 'iron/console/command_line'
require 'iron/console/argument_specification'
require 'iron/console/action'

class Console

  # Manages script meta-information (about, version, etc) plus the list of defined actions
  # that may be run.  Manages matching those actions against the command line arguments
  # to determine the correct action to run.
  class Application
    
    dsl_accessor :about, :version, :name, :author, :run_as_root
    attr_reader :action
    
    # Construct a new application, and load any library classes (see #require_all)
    def initialize
      # Init state
      @actions = []
      @base = CommandLine.instance.base
      @name = @base
      @mod_name = @base.split(/[_\-]/).collect{|s| s.capitalize}.join
      @run_as_root = false
      
      # Require all helper classes
      require_all
    end

    # Require all library classes located in <filename>-lib/
    #
    # Allows breaking out complex scripts into sub-files for easier management of code.  Files
    # are required in alphabetical order.
    def require_all
      lib_dir = File.join(CommandLine.instance.dir, "#{@name}-lib")
      search = File.join(lib_dir, '*.rb')
      Dir.glob(search).sort.each {|path| require path}
    end

    # DEPRECATED
    def actions=(vals)
      Console.br.p "Script Error:"
      Console.p "  'actions = <list>' is no longer necessary - please remove, or use 'action_priority <list>' if action ordering is required"
      Console.br
      exit
    end
    
    # Provide an explicit ordering of action priority.  Actions are matche on a first-come, first-served basis,
    # so the first action defined that can match a given command line argument list will be the one invoked.
    # In most cases, this works fine, but if you have ambiguous actions and need to specify which is tested
    # first, use this method.  Actions can be specified as full classes or as action keys.
    # 
    # Example:
    #   Console.app do
    #     action_priority :first, :second
    #   end
    #   class SecondAction < Console::Action ; end
    #   class FirstAction < Console::Action ; end
    #
    # FirstAction will attempt to match passed arguments before SecondAction, even though it was defined
    # first in code.
    #
    # Additionally, setting the action priority will alter which actions come first in the general app help.
    def action_priority(*order_list)
      @action_priority = order_list unless order_list.empty?
      @action_priority
    end
    
    # Return the list of actions defined for this app, ordered by #action_priority if specified, or
    # by order of definition if not.  All actions will be returned as the classes to invoke, ie
    # Console::HelpAction, not :help
    def actions
      # Get our ordered list if an order has been specified
      if @action_priority
        list = @action_priority.collect {|a| to_action_class(a)}
      else
        list = []
      end
      
      # Add in all remaining actions at the end of the list
      list += (@actions.collect {|a| to_action_class(a)} - list)
      
      # Ensure that the main help action (--help) and version action (--version) are at end of the list
      built_ins = [Console::VersionAction, Console::HelpAction]
      list = [Console::HelpAction] + (list - built_ins) + [Console::VersionAction]
      
      # Done!
      list
    end
    
    # Add a single action to this app's list of possible actions
    def add_action(val)
      @actions << val
    end

    # Call to execute the application.  Will parse the command line to find
    # the first matching action, and then invoke that action.  Will display
    # app help if no matching action found.
    def execute!
      # Ensure our rootness if needed, will restart script if needed
      sudo_root! if @run_as_root
      
      # Find the action to run
      @action = find_action_for(CommandLine.instance.args, CommandLine.instance.options)
      
      # Invoke the action!
      @action.invoke
    end
    
    # Given an array of (string) arguments, returns the first matching
    # action for this application, or the help action if no other action
    # is found.
    def find_action_for(args, options)
      # Build final action class list, including initial
      # help action that will match --help
      actions = self.actions
      
      # Run each action and see if it matches the script's args
      action = nil
      actions.find do |klass|
        action = klass.match(args, options)
        !action.nil?
      end
      
      # If we found no matching class, our action is help!
      action || Console::HelpAction.new
    end

    # Convert an action key to a class
    def to_action_class(val, exit_on_missing = true)
      # Simplest case
      return val if val.is_a?(Class)
      
      # Now get tricky
      klass = ''
      begin
        klass += val.to_s.split('_').collect{|s| s.capitalize}.join
        klass += 'Action'
        klass = klass.constantize
        return klass
      rescue
      end
      
      begin
        klass = @mod_name + '::' + klass
        klass = klass.constantize
        return klass
      rescue
      end

      if exit_on_missing
        Console.out do
          br
          write "Unable to find action class: "
          color(:lt_red).p klass
          br
        end
        exit
      else
        nil
      end
    end
    
    private

    # Re-run ourselves sudo'd if we're not currently running as root
    def sudo_root!
      if ENV["USER"] != "root"
        cmd = 'sudo'
        cmd = 'rvmsudo' if `which rvmsudo 2>&1`.match(/\/rvmsudo/)
        exec("#{cmd} #{ENV['_']} #{ARGV.join(' ')}")
      end
    end

  end
end
