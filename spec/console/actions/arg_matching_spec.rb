class BoolMatchAction < Console::Action
  args do
    bool 'one'
    bool 'two'
    bool 'three'
  end
end

class StringMatchAction < Console::Action
  args do
    string 'one'
    string 'two', :options => ['2', 'II']
  end
end

class OptionalMatchAction < Console::Action
  args do
    string 'one', :optional => true
  end
end

class DefaultMatchAction < Console::Action
  args do
    string 'one', :default => '1'
  end
end

class OptionalMidMatchAction < Console::Action
  args do
    string 'one'
    string 'two', :optional => true
    string 'three', :default => '3!'
    string 'four'
  end
end

class ComplexMatchAction < Console::Action
  args do
    string 'first', :optional => true
    string 'second', :optional => true
    int 'third'
    string 'fourth', :optional => true
    wildcard 'fifth'
  end
end

class EmptyAction < Console::Action
end

describe Console::Action do

  # Helper method to allow quick testing of our action matching
  def should_match(klass, args, expected_results)
    cl = Console.command_line
    cl.parse_arguments(args)
    res = klass.match(cl.args, cl.options)
    res.should be_a(klass)
    res.args.should == expected_results
  end
  
  def shouldnt_match(klass, args)
    cl = Console.command_line
    cl.parse_arguments(args)
    res = klass.match(cl.args, cl.options)
    res.should be_nil
  end

  context 'when matching arguments' do
    
    it 'should not match if too many arguments are given' do
      shouldnt_match(BoolMatchAction, ['no','no','no','extra'])
    end
    
    it 'should match bool arguments in yes/no, true/false, and on/off forms' do
      should_match(BoolMatchAction, ['yes', 'true', 'on'], {:one => true, :two => true, :three => true})
      should_match(BoolMatchAction, ['no', 'false', 'off'], {:one => false, :two => false, :three => false})
      shouldnt_match(BoolMatchAction, ['nein', 'nope', 'uh-uh'])
    end
    
    it 'should match string arguments and allow restricting options' do
      should_match(StringMatchAction, ['won', '2'], {:one => 'won', :two => '2'})
      shouldnt_match(StringMatchAction, ['tree', 'fower'])
    end
    
    it 'should require required arguments' do
      shouldnt_match(BoolMatchAction, [])
      shouldnt_match(BoolMatchAction, ['true', 'true'])
    end
    
    it 'should allow optional arguments' do
      should_match(OptionalMatchAction, [], {})
    end
    
    it 'should treat options with defaults as optional' do
      should_match(DefaultMatchAction, [], {:one => '1'})
    end
    
    it 'should allow optional arguments in the middle' do
      should_match(OptionalMidMatchAction, ['1', '2', '3', '4'], {:one => '1', :two => '2', :three => '3', :four => '4'})
      should_match(OptionalMidMatchAction, ['1', '4'], {:one => '1', :three => '3!', :four => '4'})
    end
    
    it 'should find the best match' do
      should_match(ComplexMatchAction, ['a','b','3','c','d'], {:first => 'a', :second => 'b', :third => 3, :fourth => 'c', :fifth => ['d']})
      should_match(ComplexMatchAction, ['25','hi'], {:third => 25, :fifth => ['hi']})
      should_match(ComplexMatchAction, ['a','3','d'], {:first => 'a', :third => 3, :fifth => ['d']})
      
      shouldnt_match(ComplexMatchAction, ['a','b','c','d','e']) # No int value
      shouldnt_match(ComplexMatchAction, ['10']) # No multi value
    end
    
    it 'should match when no args or options are specified' do
      should_match(EmptyAction, [], {})
    end
    
  end

end