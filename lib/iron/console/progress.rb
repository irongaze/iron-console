
class Console
  class Progress
    attr_accessor :full_char, :empty_char, :full_color, :empty_color

    def initialize
      set_style('-', '=')

      @drawn = false
      @started = false
      @val = nil

      self.width = 20
      self.range = 100
      self.show_percent = true
    end

    def range=(val)
      if val.is_a?(Range)
        @range = val
      else
        @range = 0..val
      end
      @range
    end

    def range
      @range
    end

    def width
      @width
    end

    def width=(chars)
      @width = chars
      @bar_width = chars
      @bar_width -= 2 # brackets
      @bar_width -= 5 if @show_percent
    end

    def set_style(empty, full, empty_col = :dk_gray, full_col = :white)
      @empty_char = empty
      @full_char = full
      @empty_color = empty_col
      @full_color = full_col
    end

    def show_percent
      @show_percent
    end

    def show_percent=(val)
      @show_percent = val
      self.width = @width
    end

    def start
      return if @started

      @drawn = false
      @started = true
      Console.cursor.hide
      update @range.min
    end
    
    def inc(amt = 1)
      update(@val + amt)
    end

    def update(val)
      start unless @started
      @val = @range.bound(val)
      percent = @val.to_f / (@range.max - @range.min).to_f
      full = (percent * @bar_width).to_i
      empty = @bar_width - full

      if @drawn
        Console.cursor.left(@width)
      end

      Console.color(:lt_gray).write '['
      Console.color(@full_color).write @full_char * full
      Console.color(@empty_color).write @empty_char * empty
      Console.color(:lt_gray).write ']'
      Console.color(:lt_gray).write " #{(percent*100).to_i.to_s.rjust(3)}%" if @show_percent

      # Console.output do
      #   lt_gray '['
      #   color @full_color, @full_char * full
      #   color @empty_color, @empty_char * empty
      #   lt_gray ']'
      #   lt_gray " #{(percent*100).to_i.to_s.rjust(3)}%" if @show_percent
      # end

      #con << :lt_gray << '[' << @full_color << @full_char * full <<  @empty_color << @empty_char * empty << :lt_gray << ']'
      #con << :lt_gray << " #{(percent*100).to_i.to_s.rjust(3)}%" if @show_percent

      #con << lt_gray(']') + color(@full_color, @full_char * full) + color(@empty_color, @empty_char * empty) + lt_gray(']')
      #con << lt_gray(" #{(percent*100).to_i.to_s.rjust(3)}%") if @show_percent
      
      #con.write :lt_gray['['], @full_color[@full_char * full], @empty_color[@empty_char * empty], :lt_gray[']']
      #con.write :lt_gray[" #{(percent*100).to_i.to_s.rjust(3)}%"] if @show_percent

      @drawn = true
    end

    def end
      return unless @started
      Console.cursor.show
      @started = false
    end

  end
end
