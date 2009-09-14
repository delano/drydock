

module Drydock
  module Screen
    extend self
    
    @@mutex = Mutex.new
    @@output = StringIO.new
    @@offset = 0
    @@thread = nil
    
    def print(*msg)
      @@output.print *msg
    end
    
    def puts(*msg)
      @@output.puts *msg
    end
    
    def flush
      @@mutex.synchronize do
        #return if @@offset == @@output.tell
        @@output.seek @@offset
        STDOUT.puts @@output.read unless @@output.eof?
        @@offset = @@output.tell
      end
    end
    
  end
end