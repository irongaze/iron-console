class TestOneAction < Console::Action; end
class TestTwoAction < Console::Action; end
class TestThreeAction < Console::Action; end

describe Console::Application do

  before do
    @app = Console::Application.new
  end
  
  it 'should allow setting and getting basic app info' do
    info = [:about, :version, :name, :author, :run_as_root]
    info.each do |method|
      @app.send(:"#{method}", method.length)
      @app.send(:"#{method}").should == method.length
    end
  end
  
  it 'should return Console::HelpAction first no matter what actions are defined' do
    @app.add_action(:test_one)
    @app.actions.first.should == Console::HelpAction
  end
  
  it 'should convert keys to Console::Action-derived classes' do
    @app.add_action(:test_one)
    @app.actions[1].should == TestOneAction
  end
  
  it 'should allow re-ordering actions' do
    @app.add_action(:test_one)
    @app.add_action(:test_two)
    @app.add_action(:test_three)
    @app.action_priority :test_two, :test_one, :test_three
    @app.actions[1].should == TestTwoAction
    @app.actions[2].should == TestOneAction
    @app.actions[3].should == TestThreeAction
  end
  
  it 'should put all unmentioned actions at the end of the list when re-ordering' do
    @app.add_action(:test_one)
    @app.add_action(:test_two)
    @app.add_action(:test_three)
    @app.action_priority :test_three
    @app.actions[1].should == TestThreeAction
    @app.actions[2].should == TestOneAction
    @app.actions[3].should == TestTwoAction
  end
  
end