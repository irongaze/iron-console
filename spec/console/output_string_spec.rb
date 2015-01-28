describe Console::OutputString do
  
  def string(str)
    Console::OutputString.new(str)
  end
  
  it 'should ignore escape commands when calculating length' do
    string("abcd\e[27h is good").length.should == 12
  end
  
end