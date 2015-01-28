describe Console::ArgumentSpecificationList do
  
  it 'should provide methods to define argument specs' do
    list = Console::ArgumentSpecificationList.new
    list.bool('Some Value')
    
    list.count.should == 1
    list.first.should be_a(Console::BoolSpecification)
  end
  
end