class MixedOptionAction < Console::Action
  options do
    bool 'boolean', :flag => 'b'
    int 'integer', :flag => 'i'
    string 'string', :flag => 's'
  end
end

describe Console::Action do

  # Helper method to allow quick testing of our action matching
  def should_match(klass, args, expected_results)
    cl = Console.command_line
    cl.parse_arguments(args)
    res = klass.match(cl.args, cl.options)
    res.should be_a(klass)
    res.options.should == expected_results
  end
  
  def shouldnt_match(klass, args)
    cl = Console.command_line
    cl.parse_arguments(args)
    res = klass.match(cl.args, cl.options)
    res.should be_nil
  end

  context 'when matching options' do
    
    it 'should treat all option specs as optional by default' do
      should_match(MixedOptionAction, [], {})
    end
    
    it 'should not match when extra options are given' do
      shouldnt_match(MixedOptionAction, ['-b', '--foo'])
      shouldnt_match(MixedOptionAction, ['-x'])
    end
    
    it 'should match options in flag or full form' do
      should_match(MixedOptionAction, ['-b'], {:boolean => true})
      should_match(MixedOptionAction, ['--boolean'], {:boolean => true})
      should_match(MixedOptionAction, ['--no-boolean'], {:boolean => false})
    end
    
    it 'should match options in any order' do
      should_match(MixedOptionAction, ['-b', '-i=5', '-s=yo'], {:boolean => true, :integer => 5, :string => 'yo'})
      should_match(MixedOptionAction, ['-s=yo', '-b', '-i=5'], {:string => 'yo', :boolean => true, :integer => 5})
    end

  end

end