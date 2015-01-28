require 'singleton'

class Console
  
  # Manages the arguments passed on the command line, and locates the
  # real (ie non-symlinked) location of the executable that was loaded.
  class CommandLine
    include Singleton
    
    # Base contains the name of the executable that is currently running
    attr_reader :base
    
    # Dir is the real directory in which the executable lives
    attr_reader :dir

    # Return the arguments passed on the command line to this script
    def self.args
      CommandLine.instance.args
    end
    
    # Return the options passed on the command line to this script
    def self.options
      CommandLine.instance.options
    end
    
    def initialize
      @commands = []
      @base = File.basename($0)
      @dir = find_start_dir
    end
    
    # Determine (from call stack) the location of the script that ran to start us up
    def find_start_dir
      # Get the call stack, find the first entry, strip off line/method info
      file = caller.last.gsub(/:.*$/, '')

      # Expand symlinks - we want the original file, thanks
      while File.symlink?(file)
        file = File.readlink(file)
      end
      
      # Strip off filename
      dir = file.gsub(/\/[^\/]*$/,'')
      
      # And return the expanded path
      File.expand_path(dir)      
    end
    
    # Parses (if necessary) and returns the array of values passed
    # via command line to the script
    def args
      parse_arguments(ARGV) if @args.nil?
      @args
    end
    
    # Parses (if necessary) and returns the hash of name => value options passed
    # via command line to the script
    def options
      parse_arguments(ARGV) if @options.nil?
      @options
    end
    
    # Core function of the class, takes an array of tokens from the command line and
    # breaks them out into options (like --foo or -x) and arguments (anything else)
    # for use in matching against the specifications of Console::Action derived
    # script actions.
    #
    # Automatically expands multi-character options like -xzf to -x -z -f.
    def parse_arguments(args)
      args = expand_multi_flags(args)
      args = extract_options(args)
      extract_args(args)
    end

    # Convert passed flag arguments of type '-xyz' to '-x', '-y', '-z'
    def expand_multi_flags(args)
      expanded_args = []
      args.each do |a|
        multi = a.extract(/^-([a-z]{2,})/i)
        if multi
          multi.scan(/./) {|flag| expanded_args << "-#{flag}" }  
        else
          expanded_args << a
        end
      end
      expanded_args
    end
    
    # Pulls out options and their optional assignments and returns them as a hash, ignoring
    # non-option values (presumably arguments).  Removes matched options from the args
    # array passed in.
    #
    # Example input: 
    #   ['-x', '--foo=12', '--no-bar']
    # Output:
    #   {'x' => 'true', 'foo' => '12', 'bar' => 'false'}
    def extract_options(args)
      remaining = []
      @options = {}
      args.each do |a|
        if a.starts_with?('--')
          val = 'true'
          name = a.extract(/--(.*)/)
          if name.starts_with?('no-')
            name = name.gsub(/^no-/, '')
            val = 'false'
          elsif name.include?('=')
            name, val = name.extract(/(.*)=(.*)/)
          end
          @options[name] = val
        elsif a.starts_with?('-')
          val = 'true'
          name = a.extract(/-(.*)/)
          if name.include?('=')
            name, val = name.extract(/(.*)=(.*)/)
          end
          @options[name] = val
        else
          remaining << a
        end
      end
      remaining
    end
    
    # Extract the arguments, in this case basically a no-op as everything else has already been removed
    def extract_args(args)
      @args = args
    end
  end

end
