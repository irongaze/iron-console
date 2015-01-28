class SampleAction < Console::Action

  nodoc!

  desc 'A sample action for testing'

  args do
    const 'sample'
    string 'String Arg', :default => 'foo'
  end
  
  def invoke
    'worked'
  end
end

describe Console::Action do

  it 'should be invoke-able at a class level' do
    SampleAction.invoke({}).should == 'worked'
  end
  
  it 'should provide a key for use in configuring the app' do
    SampleAction.key.should == :sample
  end
  
  it 'should allow hiding the action' do
    SampleAction.should be_nodoc
  end
  
  it 'should provide access to a general description when set' do
    SampleAction.desc.should include('sample action')
  end
  
  context 'when defining arguments' do

    it 'should remember its argument specifications' do
      SampleAction.args.count.should == 2
      SampleAction.args[0].should be_a(Console::ConstSpecification)
      SampleAction.args[1].should be_a(Console::StringSpecification)
    end

    it 'should set options on defined arguments' do
      SampleAction.args[1].should have_default
      SampleAction.args[1].default.should == 'foo'
    end

  end
  
end