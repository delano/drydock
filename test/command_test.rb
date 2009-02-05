require File.dirname(__FILE__) + "/../lib/drydock"
require "rubygems"
require "test/spec"
require "mocha"

class Test::Unit::TestCase
  def test_command_direct(cmd, argv, &b)
    Drydock::Command.new(cmd, &b).call(*argv)
  end
  def test_command(*args, &b)
    command(*args, &b)
  end
end

class JohnWestSmokedOysters < Drydock::Command; end;

Drydock.run = false

context "command" do
  
  setup do 
    @mock = mock() 
  end
  
  specify "should know a command alias" do
    @mock.expects(:called).with(:eat_alias)
    test_command_direct(:eat, [:eat_alias]) { |obj,argv| 
      @mock.called(obj.alias) 
    }
  end
  
  specify "should accept a custom command class" do
    @mock.expects(:called).with(JohnWestSmokedOysters)
    test_command(:eat => JohnWestSmokedOysters) { |obj,argv| 
      @mock.called(obj.class) 
    }
    Drydock.run!(['eat'])
  end
  
end
