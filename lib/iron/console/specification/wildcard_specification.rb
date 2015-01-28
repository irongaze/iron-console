class Console
  
  # Accepts all remaining un-matched arguments
  class WildcardSpecification < ArgumentSpecification
    def match_as_arg(in_array, out_hash)
      if in_array.empty?
        if has_default?
          # No arguments remaining, use our default
          out_hash[to_sym] = default.is_a?(Array) ? default : [default]
          return true
        else
          # No arguments, no default... are we optional?
          return optional?
        end
      else
        # Take in all remaining strings unparsed
        out_hash[to_sym] = in_array.dup
        in_array.clear
        return true
      end
    end
    
    def to_param
      optional? ? "[#{to_key}...]" : "#{to_key}..."
    end
  end    
  
end