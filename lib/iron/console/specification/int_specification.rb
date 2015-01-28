class Console

  # Accepts an integer value
  class IntSpecification < ArgumentSpecification
    def match?(val)
      val =~ /-?\d+/
    end

    def parse(val)
      val.to_i
    end
  end

end