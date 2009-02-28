require 'optparse'
require 'ostruct'


module Drydock
  # The base class for all command objects. There is an instance of this class
  # for every command defined. Global and command-specific options are added
  # as attributes to this class dynamically. 
  # 
  # i.e. "example -v date -f yaml"
  #
  #     global_option :v, :verbose, "I want mooooore!"
  #     option :f, :format, String, "Long date format"
  #     command :date do |obj|
  #         puts obj.verbose  #=> true
  #         puts obj.format  #=> "yaml"
  #     end
  #
  # You can inherit from this class to create your own: EatFood < Drydock::Command.
  # And then specific your class in the command definition:
  #
  #     command :eat => EatFood do |obj|; ...; end
  #
  class Command
    attr_reader :cmd, :alias
    attr_accessor :verbose, :desc
    
    attr_reader :options
    attr_reader :globals
    
    # The default constructor sets the short name of the command
    # and stores a reference to the block (if supplied).
    # You don't need to override this method to add functionality 
    # to your custom Command classes. Define an +init+ method instead.
    # It will be called just before the block is executed. 
    # +cmd+ is the short name of this command.
    # +b+ is the block associated to this command.
    def initialize(cmd, &b)
      @cmd = (cmd.kind_of?(Symbol)) ? cmd : cmd.to_sym
      @b = b
      @verbose = 0
      @options = OpenStruct.new
      @globals = OpenStruct.new
    end
    
    # Returns the command name (not the alias)
    def name
      @cmd
    end
    
    # Execute the block.
    # 
    # Calls self.init before calling the block. Implement this method when 
    #
    # +cmd_str+ is the short name used to evoke this command. It will equal @cmd
    # unless an alias was used used to evoke this command.
    # +argv+ an array of unnamed arguments. If ignore :options was declared this
    # will contain the arguments exactly as they were defined on the command-line.
    # +stdin+ contains the output of stdin do; ...; end otherwise it's a STDIN IO handle.
    # +global_options+ a hash of the global options specified on the command-line
    # +options+ a hash of the command-specific options specific on the command-line.
    def call(cmd_str=nil, argv=[], stdin=[], global_options={}, options={})
      @alias = cmd_str.nil? ? @cmd : cmd_str

      global_options.each_pair do |n,v|
        self.globals.send("#{n}=", v)
      end
      
      options.each_pair do |n,v|
        self.options.send("#{n}=", v)
      end
      
      self.init if respond_to? :init
      
      block_args = [self, argv, stdin] # TODO: review order
      @b.call(*block_args[0..(@b.arity-1)]) # send only as many args as defined
    end
    
    # The name of the command
    def to_s
      @cmd.to_s
    end
  end
end

module Drydock
  class UnknownCommand < RuntimeError
    attr_reader :name
    def initialize(name)
      @name = name || :unknown
    end
    def message
      "Unknown command: #{@name}"
    end
  end
  class NoCommandsDefined < RuntimeError
    def message
      "No commands defined"
    end
  end
  class InvalidArgument < RuntimeError
    attr_accessor :args
    def initialize(args)
      @args = args || []
    end
    def message
      "Unknown option: #{@args.join(", ")}"
    end
  end
  class MissingArgument < InvalidArgument
    def message
      "Option requires a value: #{@args.join(", ")}"
    end
  end
end

# Drydock is a DSL for command-line apps. 
# See bin/example for usage examples. 
module Drydock
  extend self
  
  VERSION = 0.4
  
 private
  # Disabled. We're going basic, using a module and include/extend. 
  # Stolen from Sinatra!
  #def delegate(*args)
  #  args.each do |m|
  #    eval(<<-end_eval, binding, "(__Drydock__)", __LINE__)
  #      def #{m}(*args, &b)
  #        Drydock.#{m}(*args, &b)
  #      end
  #    end_eval
  #  end
  #end
  #
  #delegate :before, :after, :alias_command, :desc
  #delegate :global_option, :global_usage, :usage, :commands, :command
  #delegate :debug, :option, :stdin, :default, :ignore, :command_alias
  
  @@debug = false
  @@has_run = false
  @@run = true
  @@default_command = nil
  
 public
  # Enable or disable debug output.
  #
  #     debug :on
  #     debug :off
  #
  # Calling without :on or :off will toggle the value. 
  #
  def debug(toggle=false)
    if toggle.is_a? Symbol
      @@debug = true if toggle == :on
      @@debug = false if toggle == :off
    else
      @@debug = (!@@debug)
    end
  end
  # Returns true if debug output is enabled. 
  def debug?
    @@debug
  end
  
  # Define a default command. 
  #
  #     default :task
  #
  def default(cmd)
    @@default_command = canonize(cmd)
  end
  
  # Define a block for processing STDIN before the command is called. 
  # The command block receives the return value of this block in a named argument:
  #
  #     command :task do |obj, argv, stdin|; ...; end
  #
  # If a stdin block isn't defined, +stdin+ above will be the STDIN IO handle. 
  def stdin(&b)
    @@stdin_block = b
  end
  
  # Define a block to be called before the command. 
  # This is useful for opening database connections, etc...
  def before(&b)
    @@before_block = b
  end
  
  # Define a block to be called after the command. 
  # This is useful for stopping, closing, etc... the stuff in the before block. 
  def after(&b)
    @@after_block = b
  end
  
  # Define the default global usage banner. This is displayed
  # with "script -h". 
  def global_usage(msg)
    @@global_options ||= OpenStruct.new
    global_opts_parser.banner = "USAGE: #{msg}"
  end
  
  # Define a command-specific usage banner. This is displayed
  # with "script command -h"
  def usage(msg)
    get_current_option_parser.banner = "USAGE: #{msg}"
  end
  
  # Grab the options parser for the current command or create it if it doesn't exist.
  # Returns an instance of OptionParser.
  def get_current_option_parser
    @@command_opts_parser ||= []
    @@command_index ||= 0
    (@@command_opts_parser[@@command_index] ||= OptionParser.new)
  end
  
  # Grabs the options parser for the given command. 
  # +arg+ can be an index or command name.
  # Returns an instance of OptionParser.
  def get_option_parser(arg)
    @@command_opts_parser ||= []
    index = arg.is_a?(String) ? get_command_index(arg) : arg
    (@@command_opts_parser[index] ||= OptionParser.new)
  end
  
  # Tell the Drydock parser to ignore something. 
  # Drydock will currently only listen to you if you tell it to "ignore :options", 
  # otherwise it will ignore you!
  # 
  # +what+ the thing to ignore. When it equals :options Drydock will not parse
  # the command-specific arguments. It will pass the arguments directly to the
  # Command object. This is useful when you want to parse the arguments in some a way
  # that's too crazy, dangerous for Drydock to handle automatically.  
  def ignore(what=:nothing)
    @@command_opts_parser[@@command_index] = :ignore if what == :options || what == :all
  end
  
  # Define a global option. See +option+ for more info. 
  def global_option(*args, &b)
    args.unshift(global_opts_parser)
    global_option_names << option_parser(args, &b)
  end
  alias :global :global_option
  
  # Define a command-specific option. 
  # 
  # +args+ is passed directly to OptionParser.on so it can contain anything
  # that's valid to that method. If a class is included, it will tell 
  # OptionParser to expect a value otherwise it assumes a boolean value. 
  # Some examples:
  #
  #     option :h, :help, "Displays this message"
  #     option '-l x,y,z', '--lang=x,y,z', Array, "Requested languages"
  #
  #     You can also supply a block to fiddle with the values. The final 
  #     value becomes the option's value:
  #
  #     option :m, :max, Integer, "Maximum threshold" do |v|
  #       v = 100 if v > 100
  #       v
  #     end
  #
  # All calls to +option+ must come before the command they're associated
  # to. Example:
  # 
  #     option :t, :tasty,          "A boolean switch"
  #     option     :reason, String, "Requires a parameter"
  #     command :task do |obj|; 
  #       obj.options.tasty       # => true
  #       obj.options.reason      # => I made the sandwich!
  #     end
  #
  # When calling your script with a specific command-line option, the value
  # is available via obj.longname inside the command block. 
  #
  def option(*args, &b)
    args.unshift(get_current_option_parser)
    current_command_option_names << option_parser(args, &b)
  end
  

  
  
  # Define a command. 
  # 
  #     command :task do
  #       ...
  #     end
  # 
  # A custom command class can be specified using Hash syntax. The class
  # must inherit from Drydock::Command (class CustomeClass < Drydock::Command)
  #
  #     command :task => CustomCommand do
  #       ...
  #     end
  #
  def command(*cmds, &b)
    @@command_index ||= 0
    @@command_opts_parser ||= []
    @@command_option_names ||= []
    cmds.each do |cmd| 
      if cmd.is_a? Hash
        c = cmd.values.first.new(cmd.keys.first, &b)
      else
        c = Drydock::Command.new(cmd, &b)
      end
      
      c.desc = @@command_descriptions[@@command_index]
      
      # Default Usage Banner. 
      # Without this, there's no help displayed for the command. 
      usage "#{$0} #{c.cmd}" if get_option_parser(@@command_index).banner !~ /^USAGE/
      
      commands[c.cmd] = c
      command_index_map[c.cmd] = @@command_index
      @@command_index += 1 # This will point to the next command
    end
    
  end
  
  # Used to create an alias to a defined command. 
  # Here's an example:
  #
  #    command :task do; ...; end
  #    alias_command :pointer, :task
  #
  # Either name can be used on the command-line:
  #
  #    $ script task [options]
  #    $ script pointer [options]
  #
  # Inside of the command definition, you have access to the
  # command name that was used via obj.alias. 
  def alias_command(aliaz, cmd)
    return unless commands.has_key? cmd
    commands[canonize(aliaz)] = commands[cmd]
  end
  
  # Identical to +alias_command+ with reversed arguments. 
  # For whatever reason I forget the order so Drydock supports both. 
  # Tip: the argument order matches the method name. 
  def command_alias(cmd, aliaz)
    return unless commands.has_key? cmd
    puts "#{canonize(aliaz)} to #{commands[cmd]}"
    commands[canonize(aliaz)] = commands[cmd]
  end
  
  # A hash of the currently defined Drydock::Command objects
  def commands
    @@commands ||= {}
    @@commands
  end
  
  # An array of the currently defined commands names
  def command_names
    @@commands ||= {}
    @@commands.keys.collect { |cmd| decanonize(cmd); }
  end
  
  # Provide a description for a command
  def desc(txt)
    @@command_descriptions ||= []
    @@command_descriptions << txt
  end
  
  # Returns true if automatic execution is enabled. 
  def run?
    @@run
  end
  
  # Disable automatic execution (enabled by default)
  #
  #     Drydock.run = false
  def run=(v)
    @@run = (v == true) ? true : false 
  end
  
  # Return true if a command has been executed.
  def has_run?
    @@has_run
  end
  
  # Execute the given command.
  # By default, Drydock automatically executes itself and provides handlers for known errors.
  # You can override this functionality by calling +Drydock.run!+ yourself. Drydock
  # will only call +run!+ once. 
  def run!(argv=[], stdin=STDIN)
    return if has_run?
    @@has_run = true
    raise NoCommandsDefined.new if commands.empty?
    @@global_options, cmd_name, @@command_options, argv = process_arguments(argv)
    
    cmd_name ||= default_command
    
    raise UnknownCommand.new(cmd_name) unless command?(cmd_name)
    
    stdin = (defined? @@stdin_block) ? @@stdin_block.call(stdin, []) : stdin
    @@before_block.call if defined? @@before_block
    
    call_command(cmd_name, argv, stdin)
    
    @@after_block.call if defined? @@after_block
    
  rescue OptionParser::InvalidOption => ex
    raise Drydock::InvalidArgument.new(ex.args)
  rescue OptionParser::MissingArgument => ex
    raise Drydock::MissingArgument.new(ex.args)
  end
  
 private 
  
  # Executes the block associated to +cmd+
  def call_command(cmd, argv=[], stdin=nil)
    return unless command?(cmd)
    get_command(cmd).call(cmd, argv, stdin, @@global_options || {}, @@command_options || {})
  end
  
  # Returns the Drydock::Command object with the name +cmd+
  def get_command(cmd)
    return unless command?(cmd)
    @@commands[canonize(cmd)]
  end 
  
  # Returns true if a command with the name +cmd+ has been defined. 
  def command?(cmd)
    name = canonize(cmd)
    (@@commands || {}).has_key? name
  end
  
  # Canonizes a string (+cmd+) to the symbol for command names
  # '-' is replaced with '_'
  def canonize(cmd)
    return unless cmd
    return cmd if cmd.kind_of?(Symbol)
    cmd.to_s.tr('-', '_').to_sym
  end
  
  # Returns a string version of +cmd+, decanonized.
  # Lowercase, '_' is replaced with '-'
  def decanonize(cmd)
    return unless cmd
    cmd.to_s.tr('_', '-')
  end
  
  # Processes calls to option and global_option. Symbols are converted into 
  # OptionParser style strings (:h and :help become '-h' and '--help'). 
  def option_parser(args=[], &b)
    return if args.empty?
    opts_parser = args.shift
    
    arg_name = ''
    symbol_switches = []
    args.each_with_index do |arg, index|
      if arg.is_a? Symbol
        arg_name = arg.to_s if arg.to_s.size > arg_name.size
        args[index] = (arg.to_s.length == 1) ? "-#{arg.to_s}" : "--#{arg.to_s}"
        symbol_switches << args[index]
      elsif arg.kind_of?(Class)
        symbol_switches.each do |arg|
          arg << "=S"
        end
      end
    end
    
    if args.size == 1
      opts_parser.on(args.shift)
    else
      opts_parser.on(*args) do |v|
        block_args = [v, opts_parser]
        result = (b.nil?) ? v : b.call(*block_args[0..(b.arity-1)])
      end
    end
    
    arg_name
  end
  
  
  # Split the +argv+ array into global args and command args and 
  # find the command name. 
  # i.e. ./script -H push -f (-H is a global arg, push is the command, -f is a command arg)
  # returns [global_options, cmd, command_options, argv]
  def process_arguments(argv=[])
    global_options = command_options = {}
    cmd = nil     
    
    global_options = global_opts_parser.getopts(argv)
          
    cmd_name = (argv.empty?) ? @@default_command : argv.shift
    raise UnknownCommand.new(cmd_name) unless command?(cmd_name)
    
    cmd = get_command(cmd_name) 
    
    command_parser = @@command_opts_parser[get_command_index(cmd.cmd)]
    command_options = {}
    
    # We only need to parse the options out of the arguments when
    # there are args available, there is a valid parser, and 
    # we weren't requested to ignore the options. 
    if !argv.empty? && command_parser && command_parser != :ignore
      command_options = command_parser.getopts(argv)
    end
    
    # Add accessors to the Drydock::Command object 
    # for the global and command specific options
    [global_option_names, (command_option_names[get_command_index(cmd_name)] || [])].flatten.each do |n|
      unless cmd.respond_to?(n)
        cmd.class.send(:define_method, n) do
          instance_variable_get("@#{n}")
        end
      end
      unless cmd.respond_to?("#{n}=")
        cmd.class.send(:define_method, "#{n}=") do |val|
          instance_variable_set("@#{n}", val)
        end
      end
    end
    
    [global_options, cmd_name, command_options, argv]
  end
  
  def global_option_names
    @@global_option_names ||= []
  end
  
  # Grab the current list of command-specific option names. This is a list of the
  # long names. 
  def current_command_option_names
    @@command_option_names ||= []
    @@command_index ||= 0
    (@@command_option_names[@@command_index] ||= [])
  end
  
  def command_index_map
    @@command_index_map ||= {}
  end
  
  def get_command_index(cmd)
    command_index_map[canonize(cmd)] || -1
  end
  
  def command_option_names
    @@command_option_names ||= []
  end
  
  def global_opts_parser
    @@global_opts_parser ||= OptionParser.new
  end
  
  def default_command
    @@default_command ||= nil
  end
  
end



trap ("SIGINT") do
  puts "#{$/}Exiting..."
  exit 1
end


at_exit {
  begin
    Drydock.run!(ARGV, STDIN) if Drydock.run? && !Drydock.has_run?
  rescue => ex
    STDERR.puts "ERROR: #{ex.message}"
    STDERR.puts ex.backtrace if Drydock.debug?
  end
}

  
