class Console

  # Accepts a true/false value
  class BoolSpecification < ArgumentSpecification
    def match?(val)
      ['yes', 'no', 'true', 'false', 'on', 'off'].include?(val)
    end
    
    def parse(val)
      case val
      when 'yes', 'true', 'on' then
        true
      when 'no', 'false', 'off' then
        false
      else
        raise ArgumentError.new('Invalid boolean value: ' + val.inspect)
      end
    end
  end
  
end