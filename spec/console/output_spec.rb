describe Console::Output do
  
  before do
    @output = Console.output
  end
  
  it 'should track the current indent level' do
    @output.indent_level.should == 0
    Console.indent do
      @output.indent_level.should == 2
      indent(5) do
        @output.indent_level.should == 7
      end
      @output.indent_level.should == 2
    end
    @output.indent_level.should == 0
  end
  
end