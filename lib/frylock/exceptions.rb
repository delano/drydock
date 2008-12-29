module Frylock
  class UnknownCommand < RuntimeError
    attr_reader :name
    def initialize(name)
      @name = name || :unknown
    end
    def message
      msg = "Frylock: I don't know what that #{@name} command is. #{$/}"
      msg << "Master Shake: I'll tell you what it is, friends... it's shut up and let me eat it."
    end
  end
  class NoCommandsDefined < RuntimeError
    def message
      msg = "Frylock: Carl, I don't want it. And I'd appreciate it if you'd define at least one command. #{$/}"
      msg << "Carl: Fryman, don't be that way! This sorta thing happens every day! People just don't... you know, talk about it this loud."
    end
  end
  class InvalidArgument < RuntimeError
    attr_accessor :args
    def initialize(args)
      # We grab just the name of the argument
      @args = args || []
    end
    def message
      msg = "Frylock: I don't know what #{@args.join(', ')} is. #{$/}"
      msg << "Master Shake: I'll tell you what it is, friends... it's shut up and let me eat it."
    end
  end
  class MissingArgument < InvalidArgument
    def message
      msg = "Frylock: Shake, how many arguments have you not provided a value for this year? #{$/}"
      msg << "Master Shake: A *lot* more than *you* have! (#{@args.join(', ')})"
    end
  end
  
end
