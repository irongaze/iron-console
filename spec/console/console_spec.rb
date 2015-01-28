describe Console do

  it 'should be a singleton' do
    Console.should respond_to(:instance)
    Console.instance.should be_a(Singleton)
  end

  it 'should write to stdout' do
    res = capture_stdout do 
      Console.writeln 'Hello world!'
    end
    res.should == "Hello world!\n"
  end

  it 'should indent text multiple levels' do
    res = Kernel.capture_stdout do 
      Console.indent do
        write 'hi mom'
        indent do
          write 'again'
        end
      end
    end
    res.should == "  hi mom\n    again\n"
  end

  it 'should allow concatenation on a single line' do
    res = capture_stdout do 
      Console.write 'alpha'
      Console.writeln 'bet'
    end
    res.should == "alphabet\n"
  end

  it 'should support colors' do
    res = capture_stdout do 
      Console.color(:dk_red).writeln 'bob'
    end
    res.should == "\e[0;31mbob\e[0m\n"
  end
  
  it 'should reject invalid colors' do
    Console.valid_color?(:foo).should be_false
    lambda { Console.color(:foo) }.should raise_error
  end

  context 'when outputting in a block' do
    
    it 'should handle receiver-less calls' do
      res = capture_stdout do
        Console.out do
          p 'hi mom'
        end
      end
      res.should == "hi mom\n"
    end
    
    it 'should respond_to? all methods it actually supports' do
      Console.instance.respond_to?(:writeln).should be_true
      Console.instance.respond_to?(:clear_screen).should be_true
      Console.instance.respond_to?(:foobaz).should be_false
    end

    it 'should allow access to context-defined methods' do
      def testfunc
        25
      end
      res = capture_stdout do
        Console.out do
          p "#{testfunc} chickens"
        end
      end
      res.should == "25 chickens\n"
    end
    
    it 'should allow access to context-defined local variables' do
      local_var = 'local'
      res = capture_stdout do
        Console.out do
          p local_var
        end
      end
      res.should == "local\n"
    end

    it 'should allow access to context-defined instance variables' do
      @instance_var = 'instance'
      res = capture_stdout do
        Console.out do
          p @instance_var
        end
      end
      res.should == "instance\n"
    end
    
  end

  context 'when defining app' do
    
    it 'should allow setting app options' do
      Console.app do
        version '3.1.4'
        name 'Optional App'
      end
      Console.app.name.should == 'Optional App'
      Console.app.version.should == '3.1.4'
    end

  end

end
