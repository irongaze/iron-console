
# Turn off stdout buffering
STDOUT.sync = true

# Does the heavy lifting of all console output.
#
# TODO: implement color and status stacks
#
# Should be able to push color state, change colors, then pop the old color state, ditto for statuses
#
# TODO: better support for colors, statuses, etc eg the following sample:
#
#   p dk_gray(' - [') + blink(lt_green(' Dry Run ')) + dk_gray(']')
#
# i.e. turn the status/color codes into methods
# each method should set the current state of the output if no block/arg is given
#   if an arg is given, it should set the color/status, output the text, then reset the state
#   if a block is given, it should function exactly like the out method, after setting the
#     color/status, then reset state after the block returns
#
# TODO: wrap lines
#
# Would be *great* to do indent { p "some very very long text..." } and have the wrapped lines be indented as well.
# To do this, need to keep track of the x pos of the cursor somehow.  Couldn't find any way to actually just *get* it,
# though we might be able to get ncurses support in and use that (would be a very smart long-term move...)
#
class Console
  class Output

    TERM_CODES = {
      :cursor_hide => '?25l',
      :cursor_show => '?25h',
      :cursor_up => '#A',
      :cursor_down => '#B',
      :cursor_right => '#C',
      :cursor_left => '#D',
      :cursor_xpos => '#G',
      :cursor_pos => '#;#H',
      :cursor_save => 's',
      :cursor_restore => 'u',
      :clear_screen => '2J',
      :set_color => '#m',
      :set_bg_color => '#m',
      :set_effect => '#m',
      :reset => '0m'
    }.freeze

    TERM_COLORS = {
      :black =>     '0;0',
      :dk_gray =>   '1;0',
      :dk_grey =>   '1;0',
      :dk_red =>    '0;1',
      :lt_red =>    '1;1',
      :dk_green =>  '0;2',
      :lt_green =>  '1;2',
      :dk_yellow => '0;3',
      :lt_yellow => '1;3',
      :dk_blue =>   '0;4',
      :lt_blue =>   '1;4',
      :dk_purple => '0;5',
      :lt_purple => '1;5',
      :dk_cyan =>   '0;6',
      :lt_cyan =>   '1;6',
      :lt_gray =>   '0;7',
      :lt_grey =>   '0;7',
      :white =>     '1;7',
      :default =>   '0;9'
    }.freeze

    TERM_EFFECTS = {
      :reset => 0,
      :bright => 1,
      :italic => 3,
      :underline => 4,
      :blink => 5,
      :inverse => 7,
      :hide => 8,
    }.freeze

    TERM_COLORS_IDS = {
      :black => 0,
      :red => 1,
      :green => 2,
      :yellow => 3,
      :blue => 4,
      :magenta => 5,
      :cyan => 6,
      :white => 7,
      :default => 9,
    }.freeze

    def initialize(indent = 0, buffer = false)
      @indent = indent
      @buffering = buffer
      @buffer = ''
      @new_line = true
      @need_reset = false
      @suppress_reset = false
    end
    
    def buffering?
      @buffering
    end

    def new_line?
      @new_line
    end
    
    def <<(t)
      write(t)
    end
    
    def writeln(t = '')
      write(t, true)
    end
    
    def write(t, endline = false)
      # Strip trailing newline if any
      t = t.to_s
      if t.ends_with?("\n")
        t = t[0...-1]
        endline = true
      end 
      # Reset console colors/effects
      t += to_code(:reset) if @need_reset && !@suppress_reset
      # Re-add newline
      t += "\n" if endline
      
      # Print it out!
      t.each_line do |line|
        line = ' '*@indent + line if new_line?
        if buffering?
          @buffer << line
        else
          print line
        end
      end

      # Are we on a new line?
      @new_line = t.ends_with?("\n")

      # Return self to allow chaining
      self
    end
        
    def end_line
      write "\n" unless new_line?
    end

    # Concise and easy to read...
    def p(*args)
      writeln(*args)
    end

    # Newline, by gum
    def br
      writeln
    end

    # Draw a horizontal rule
    def hr(col = :dk_gray, width = nil)
      width ||= Console.screen.width - @indent - 1
      end_line
      color(col).writeln '-'*width
    end

    def clear_screen
      code(:clear_screen)
      code(:cursor_pos, 0, 0)
    end

    def indent(amt = 2, &block) # :yields:
      indent_to(@indent + amt, &block)
    end
    
    def indent_to(col, &block) # :yields:
      end_line
      orig = @indent
      @indent = col
      if block
        DslProxy.exec(Console.instance, &block)
        @indent = orig
        end_line
      else
        self
      end
    end
    
    def reset_indent
      @indent = 0
      self
    end
    
    # Get the current indent level
    def indent_level
      @indent
    end
    
    def valid_color?(col)
      return false unless col.is_a?(Symbol)
      !TERM_COLORS[col].nil?
    end
    
    def color(col)
      code(:set_color, col)
      self
    end
    
    def bg_color(col) 
      code(:set_bg_color, col)
      self
    end

    def code(*args)
      @suppress_reset = true
      write to_code(*args)
      @suppress_reset = false
      self
    end

    def to_code(key, arg1 = nil, arg2 = nil)
      # Look up code and validate
      str = TERM_CODES[key]
      raise ArgumentError.new("Unknown terminal code: #{key}") unless str
      str = str.dup
      args = str.count('#')
      if args == 1 && arg1.nil? || args == 2 && arg2.nil?
        raise ArgumentError.new("Missing arg #{args} when setting code #{key}")
      end

      # Per-key mods
      case key
      when :cursor_pos, :cursor_xpos then
        # Positions in ANSI are 1-based
        arg1 += 1 unless arg1.to_s.blank?
        arg2 += 1 unless arg2.to_s.blank?
      when :set_color, :set_bg_color then
        # Get color vals if needed, then add appropriate fg/bg vals
        raise ArgumentError.new("Unknown color #{arg1} when setting color") unless valid_color?(arg1)
        arg1 = TERM_COLORS[arg1].dup 
        arg1.sub!(/[0-9]+$/) {|i| (i.to_i + (key == :set_color ? 30 : 40)).to_s}
        @need_reset = true
      when :set_effect
        # Look up effect if needed
        arg1 = TERM_EFFECTS[arg1] if arg1.is_a?(Symbol)
        @need_reset = true
      when :reset
        @need_reset = false
      end

      # Sub in args and write it out
      str.sub!('#', arg1.to_s) if args > 0
      str.sub!('#', arg2.to_s) if args > 1
      return "\e[#{str}"
    end
    
    def bright
      code(:set_effect, :bright)
      self
    end
    
    def underline
      code(:set_effect, :underline)
      self
    end

    def italic
      code(:set_effect, :italic)
      self
    end
    
    # Flush all buffered output to the screen, resets buffer
    def flush
      return unless buffering?
      
      @buffering = false
      write @buffer
      @buffering = true
      @buffer = ''
    end
    
    # Return an array of lines of max-length no more than width,
    # breaking at word boundaries where possible.
    # def wrap(string, width)
    #   lines = string.split(/\r?\n/)
    # end

  end
end
