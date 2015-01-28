require 'singleton'
require 'readline'
require 'iron/console/output'
require 'iron/console/command_line'
require 'iron/console/application'
require 'iron/console/cursor'
require 'iron/console/screen'
require 'iron/console/progress'

# Make sure all output gets handled
at_exit { Console.end_line ; Console.flush }

# Manages console input and output
class Console
  include Singleton
  attr_reader :output

  # Only should be done once per invocation, creates base output
  def initialize
    @output = Output.new
  end

  # Promote object-level methods to class level
  def self.method_missing(method, *args, &block)
    instance = Console.instance
    return instance.send(method, *args, &block)
  end

  # Pass output methods on to our output object
  def method_missing(method, *args, &block)
    if @output.respond_to?(method)
      return @output.send(method, *args, &block)
    end
    return super
  end
  
  # Make sure we quack like an Output duck
  def respond_to_missing?(method, allow_private)
    @output.respond_to?(method, allow_private)
  end

  # Creates a new application class, associates it with the console,
  # and returns it.  Call with a block to init the application.  If
  # an application has already been defined, returns it.
  def app(&block) # :yields:
    @app ||= Console::Application.new
    if block
      DslProxy.exec(@app, &block)
    end
    @app
  end

  # Call to actually run the app
  def execute!
    if @app
      @app.execute!
    else
      raise "No application defined for Console.execute! call: You need a Console.app do |app| ... end definition before calling Console.execute! in your script."
    end
  end

  # Create a console output block
  def out(&block) # :yields:
    DslProxy.exec(self, &block)
  end
  
  # Have to manually override this to overcome the base p() method from Kernel
  def p(txt)
    @output.p(txt)
  end

  # Return the command line singleton
  def command_line
    CommandLine.instance
  end

  # Get the cursor for this console
  def cursor
    @cursor ||= Console::Cursor.new
    @cursor
  end
  
  # Get the screen representation (aka terminal)
  def screen
    @screen ||= Console::Screen.new
    @screen
  end

  # Get the progress bar for this console
  def progress(range = nil)
    @progress ||= Console::Progress.new
    @progress.range = range unless range.nil?
    if block_given?
      yield @progress
      @progress.end
    end
    @progress
  end
  
  def prompt(prompt)
    write "#{prompt} "
    #begin
      val = Readline.readline || ''
    # rescue Interrupt => e
    #   br
    #   color(:lt_red).p "  Aborted!"
    #   br
    #   exit
    # rescue Object
    #   p ""
    #   val = ''
    # end
    val.strip
  end

  def confirm?(prompt_text)
    unless prompt("#{prompt_text} [y/N]").downcase == 'y'
      br
      color(:lt_red).p "  Aborted!"
      br
      exit
    end
    true
  end

  def select(items, prompt="Select item")
    indent do
      items.each_with_index do |item, index|
        p "#{index+1}: #{item.to_s}"
      end
    end
    br
    i = prompt(prompt).to_i
    if i>0 && i <= items.size
      return i-1
    else
      return nil
    end
  end

end
