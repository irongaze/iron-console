class Console
  
  # Derived String class that overrides core methods to handle working with
  # escape codes, while also providing console-specific helper methods
  class OutputString < String
    
    # Matches escape sequences used in our output
    ESCAPE_REGEX = /\e\[[0-9\,]*[a-zA-Z]/
    
    alias_method :raw_length, :length
    def length
      self.gsub(ESCAPE_REGEX, '').raw_length
    end
    
    def lines
      self.split(/\r?\n/).collect {|l| OutputString.new(l)}
    end
    
    def wrap(width, start_width = nil)
      res = []
      first = true
      start_width ||= width
      lines.each do |line|
        max = first ? start_width : width
        if line.length > max 
          
        else
          res << line
        end
        first = false
      end
    end
    
  end
  
end