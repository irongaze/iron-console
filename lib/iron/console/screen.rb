
# Rudimentary screen info
# TODO: use more portable info source, color caps, etc
class Console
  class Screen
    
    def initialize
      
    end
    
    def width
      get_info
      @width
    end
    
    def height
      get_info
      @height
    end
    
    def get_info
      return if @info_loaded
      @height, @width = `stty size`.split(/\s+/).map(&:to_i)
      @info_loaded = true
    end
    
    def reload_info
      @info_loaded = false
      get_info
    end
    
  end
end