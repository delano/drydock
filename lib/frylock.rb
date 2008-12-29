require 'optparse'
require 'ostruct'
require 'pp'

require 'frylock/exceptions'

module Frylock
  class Command
    attr_reader :cmd, :index
    def initialize(cmd, index, &b)
      @cmd = (cmd.kind_of?(Symbol)) ? cmd.to_s : cmd
      @index = index
      @b = b
    end
    
    def call(cmd_str, argv, stdin, global_options, options)
      block_args = [options, argv, global_options, stdin, cmd_str, self]
      @b.call(*block_args[0..(@b.arity-1)])
    end
    def to_s
      @cmd.to_s
    end
  end
end

module Frylock
  extend self
  
  FORWARDED_METHODS = %w(command before alias_command global_option global_usage usage option stdin default commands).freeze
  
  def default(cmd)
    @default_command = canonize(cmd)
  end
  
  def stdin(&b)
    @stdin_block = b
  end
  def before(&b)
    @before_block = b
  end
  
  # global_usage
  # ex: usage "Usage: frylla [global options] command [command options]"
  def global_usage(msg)
    @global_opts_parser ||= OptionParser.new 
    @global_options ||= OpenStruct.new
  
    @global_opts_parser.banner = msg
  end
  

  
  # process_arguments
  #
  # Split the +argv+ array into global args and command args and 
  # find the command name. 
  # i.e. ./script -H push -f (-H is a global arg, push is the command, -f is a command arg)
  # returns [global_options, cmd, command_options, argv]
  def process_arguments(argv)
    global_options = command_options = {}
    cmd = nil     
    
    global_parser = @global_opts_parser
    
    global_options = global_parser.getopts(argv)
    global_options = global_options.keys.inject({}) do |hash, key|
       hash[key.to_sym] = global_options[key]
       hash
    end
    
    cmd_name = (argv.empty?) ? @default_command : argv.shift
    raise UnknownCommand.new(cmd_name) unless command?(cmd_name)
    
    cmd = get_command(cmd_name) 
    command_parser = @command_opts_parser[cmd.index]
    
    command_options = command_parser.getopts(argv) if (!argv.empty? && command_parser)
    command_options = command_options.keys.inject({}) do |hash, key|
       hash[key.to_sym] = command_options[key]
       hash
    end
    
    [global_options, cmd_name, command_options, argv]
  end
  

  
  def usage(msg)
    get_current_option_parser.banner = msg
  end
  
  # get_current_option_parser
  #
  # Grab the options parser for the current command or create it if it doesn't exist.
  def get_current_option_parser
    @command_opts_parser ||= []
    @command_index ||= 0
    (@command_opts_parser[@command_index] ||= OptionParser.new)
  end
  
  def global_option(*args, &b)
    @global_opts_parser ||= OptionParser.new
    args.unshift(@global_opts_parser)
    option_parser(args, &b)
  end
  
  def option(*args, &b)
    args.unshift(get_current_option_parser)
    option_parser(args, &b)
  end
  
  # option_parser
  #
  # Processes calls to option and global_option. Symbols are converted into 
  # OptionParser style strings (:h and :help become '-h' and '--help'). If a 
  # class is included, it will tell OptionParser to expect a value otherwise
  # it assumes a boolean value.
  #
  # +args+ is passed directly to OptionParser.on so it can contain anything
  # that's valid to that method. Some examples:
  # [:h, :help, "Displays this message"]
  # [:m, :max, Integer, "Maximum threshold"]
  # ['-l x,y,z', '--lang=x,y,z', Array, "Requested languages"]
  def option_parser(args=[], &b)
    return if args.empty?
    opts_parser = args.shift
    
    symbol_switches = []
    args.each_with_index do |arg, index|
      if arg.is_a? Symbol
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
  end
  
  def command(*cmds, &b)
    @command_index ||= 0
    @command_opts_parser ||= []
    cmds.each do |cmd| 
      c = Command.new(cmd, @command_index, &b)
      (@commands ||= {})[cmd] = c
    end
    
    @command_index += 1
  end
  
  def alias_command(aliaz, cmd)
    return unless @commands.has_key? cmd
    @commands[aliaz] = @commands[cmd]
  end
  
  def run!(argv, stdin=nil)
    raise NoCommandsDefined.new unless @commands
    @global_options, cmd_name, @command_options, argv = process_arguments(argv)
    
    cmd_name ||= @default_command
    
    raise UnknownCommand.new(cmd_name) unless command?(cmd_name)
    
    stdin = (defined? @stdin_block) ? @stdin_block.call(stdin, []) : stdin
    @before_block.call if defined? @before_block
    
    
    call_command(cmd_name, argv, stdin)
    
    
  rescue OptionParser::InvalidOption => ex
    raise Frylock::InvalidArgument.new(ex.args)
  rescue OptionParser::MissingArgument => ex
    raise Frylock::MissingArgument.new(ex.args)
  end
  
  
  def call_command(cmd_str, argv=[], stdin=nil)
    return unless command?(cmd_str)
    get_command(cmd_str).call(cmd_str, argv, stdin, @global_options, @command_options)
  end
  
  def get_command(cmd)
    return unless command?(cmd)
    @commands[canonize(cmd)]
  end 
  
  def commands
    @commands
  end
  
  def run
    @run || true
  end
  
  def run=(v)
    @run = v
  end
  
  def command?(cmd)
    name = canonize(cmd)
    (@commands || {}).has_key? name
  end
  def canonize(cmd)
    return unless cmd
    return cmd if cmd.kind_of?(Symbol)
    cmd.tr('-', '_').to_sym
  end
  
end

Frylock::FORWARDED_METHODS.each do |m|
  eval(<<-end_eval, binding, "(Frylock)", __LINE__)
    def #{m}(*args, &b)
      Frylock.#{m}(*args, &b)
    end
  end_eval
end



  
