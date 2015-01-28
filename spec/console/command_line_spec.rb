
describe Console::CommandLine do
  
  before do
    @command_line = Console.command_line
  end
  
  it 'should know what file ran it' do
    # We're always run from rspec, so here you go... :-)
    @command_line.base.should == 'rspec'
  end
  
  it 'should parse out and capture program arguments' do
    @command_line.parse_arguments(['one', 'two', '3'])
    @command_line.args.should == ['one', 'two', '3']
  end
  
  it 'should expand multi-flag options' do
    @command_line.parse_arguments(['--single', '-xzf', '--another-single'])
    @command_line.options.should == {'single' => 'true', 'x' => 'true', 'z' => 'true', 'f' => 'true', 'another-single' => 'true'}
  end
  
  it 'should capture option assignments' do
    @command_line.parse_arguments(['--flag=bob', '-x=y'])
    @command_line.args.should be_empty
    @command_line.options.should == {'flag' => 'bob', 'x' => 'y'}
  end
  
  it 'should capture options in any location' do
    @command_line.parse_arguments(['--flag1=one', 'arg1', '--flag2=two', 'arg2', '--flag3=three'])
    @command_line.args.should == ['arg1', 'arg2']
    @command_line.options.should == {'flag1' => 'one', 'flag2' => 'two', 'flag3' => 'three'}
  end
  
end