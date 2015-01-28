
class Console
  
  # Implements --help and help <action key> support for all scripts.
  class HelpAction < Action
    
    # Don't show when users ask for help
    nodoc!
    
    # Define our arguments
    args do
      const 'help'
      string 'action', :optional => true
    end
    
    # Take action
    def invoke
      # Get our application
      app = Console.app

      # Find single action to display usage for, or list of all actions that can be
      # searched on
      action = Console.app.to_action_class(args[:action], false)
      available_actions = app.actions.select {|a| !a.nodoc?}
      if action.nil? && available_actions.count == 1
        action = available_actions.first
      end
      
      if action
        # Print out usage for the specified action
        action.to_help
        
      else
        # Print out all available actions, plus script's general information
        Console.out do
          indent do
            # Write out application info
            br
            bright.p "#{app.name}"
            p "Version: #{app.version}" unless app.version.nil?
            p "Author: #{app.author}" unless app.author.nil?
            hr
            br

            unless app.about.blank?
              p 'About:'
              indent do
                br
                p app.about
                br
              end
            end

            p 'Available Actions:'
            indent do
              br
              info = available_actions.collect do |action|
                [action.key, action.desc || action.display_name]
              end
              info.each do |name, desc|
                write name
                write ' '
                write desc
                end_line
              end
              br
              p "Run '#{app.name} help <action>' for details on using any of the above actions"
              br
            end
          end
        end
      end

    end

  end
end
