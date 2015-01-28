class Console
  
  # Implement --version support for all scripts, simply printing out
  # the current script's app version.
  class VersionAction < Action
    
    # Don't show when users ask for help
    nodoc!

    # Only one option, and it's required
    options(:all) do
      bool 'version'
    end

    # Print out app version, or 1.0 if none specified
    def invoke
      Console.p Console.app.version || '1.0'
    end
    
  end
  
end