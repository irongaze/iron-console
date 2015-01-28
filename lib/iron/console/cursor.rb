
# Make sure we re-show cursor
at_exit { Console.cursor.show }

# Represents the cursor for the console, and provides methods
# for moving and updating it.
class Console
  class Cursor
    def initialize
      @visible = true
    end

    def move(x, y)
      (x < 0) ? left(x.abs) : right(x)
      (y < 0) ? up(y.abs) : down(y)
      self
    end

    def move_to(x, y = nil)
      if y.nil?
        Console.code(:cursor_xpos, x)
      else
        Console.code(:cursor_pos, x, y)
      end
      self
    end

    def left(n = 1)
      Console.code(:cursor_left, n)
      self
    end

    def right(n = 1)
      Console.code(:cursor_right, n)
      self
    end

    def up(n = 1)
      Console.code(:cursor_up, n)
      self
    end

    def down(n = 1)
      Console.code(:cursor_down, n)
      self
    end

    def show(val = true)
      unless @visible == val
        Console.code(val ? :cursor_show : :cursor_hide)
        @visible = val
      end
      self
    end

    def hide
      show(false)
      self
    end

    def save
      Console.code(:cursor_save)
      self
    end

    def restore
      Console.code(:cursor_restore)
      self
    end
  end
end
