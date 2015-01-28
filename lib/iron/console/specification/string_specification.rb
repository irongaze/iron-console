class Console

  # Accepts an arbitrary string value, with optional list of acceptable options
  class StringSpecification < ArgumentSpecification
    attr_accessor :options
    
    def initialize(name, desc = nil, params = {})
      super(name, desc, params)
      @options = @params[:options] || @params[:choose] || []
      @options = @options.to_a unless @options.is_a?(Array)
    end

    def match?(val)
      @options.empty? || @options.include?(val)
    end

    def to_param
      key = case @options.count
      when 0 then
        "\"<#{@name.downcase}>\""
      when 1 then
        @options.first
      else
        "<#{@options.join('|')}>"
      end
      optional? ? "[#{key}]" : key
    end

    # def to_usage
    #   # Don't show options if there aren't any
    #   return nil if @options.size == 1 && !@parent.is_a?(SetArg)
    #   details = super
    #   unless @options.empty? || @options.size == 1
    #     details += "\n\tPossible values: " + @options.join(', ') 
    #   end
    #   details
    # end

  end
  
end