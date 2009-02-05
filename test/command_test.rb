require File.dirname(__FILE__) + "/../lib/drydock"
require "rubygems"
require "test/spec"
require "mocha"

class Test::Unit::TestCase
  def test_command(cmd, argv, &b)
    Drydock::Command.new(cmd, &b).call(argv)
  end
end

Drydock.run = false

context "command" do
  
  setup do 
    @mock = mock() 
  end
  
  specify "should know a symbol is the full command name" do
    @mock.expects(:called).with()
    test_command(:foo) { @mock.called }
  end

  
end
