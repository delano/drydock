module Drylock
  
  class UnknownCommand < RuntimeError
    attr_reader :name
    def initialize(name)
      @name = name || :unknown
    end
  end
  
  class NoCommandsDefined < RuntimeError
  end
  
  class InvalidArgument < RuntimeError
    attr_accessor :args
    def initialize(args)
      # We grab just the name of the argument
      @args = args || []
    end
  end
  
  class MissingArgument < InvalidArgument
  end
  
end
