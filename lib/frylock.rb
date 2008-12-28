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
    
    def call(stdin, global_options, cmd, argv)
      argv.unshift(cmd)
      if (@b.arity == -1 || argv.size - 1 == @b.arity)
        @b.call(*argv)
      elsif (@b.arity == 2)
        @b.call(global_options, *argv)  
      elsif (@b.arity == 3)
        @b.call(stdin, global_options, *argv)
      end
    end
    def to_s
      @cmd.to_s
    end
  end
end

module Frylock
  extend self
  
  FORWARDED_METHODS = %w(command before alias_command global_option global_options usage option stdin default)

  def default(cmd)
    @default_command = canonize(cmd)
  end
  
  def stdin(&b)
    @stdin_block = b
  end
  def before(&b)
    @before_block = b
  end
  # usage
  # ex: usage "Usage: frylla [global options] command [command options]"
  def usage(msg)
    @global_opts_parser ||= OptionParser.new 
    @global_options ||= OpenStruct.new
  
    @global_opts_parser.banner = msg
  end
  

  
  # process_arguments
  #
  # Split the +argv+ array into global args and command args and 
  # find the command name. 
  # i.e. ./script -H push -f (-H is a global arg, push is the command, -f is a command arg)
  # returns [global_argv, cmd, command_argv]
  def process_arguments(argv)
    global_options = command_options = {}
    cmd = nil     
    
    global_parser = @global_opts_parser
    global_options = global_parser.getopts(argv)
    
    cmd = get_command(argv.shift) unless argv.empty?
    
    
    unless (argv.empty?)
      
      command_parser = @command_opts_parser[cmd.index]
      puts @command_opts_parser.size
      command_options = command_parser.getopts(argv)
    end
    
    pp [global_options, cmd.to_s, command_options]
    [global_options, cmd.to_s, command_options]
  end
  
  def global_options(cmd=false, &b)
    
    @global_opts_parser ||= OptionParser.new 
    @global_options ||= OpenStruct.new
    
    b.call(@global_opts_parser, @global_options)
          
  end
  
  def global_option(short, long='', msg='', &b)
    @global_opts_parser ||= OptionParser.new 
    @global_options ||= OpenStruct.new
    
    short_str = "-#{short.to_s}"
    long_str = "--#{long.to_s}"
    
    @global_opts_parser.on(short_str, long_str, msg) do |v|
      block_args = [v, @global_opts_parser]
      result = (b.nil?) ? v : b.call(block_args[0..(b.arity-1)])
      @global_options.send("#{long}=", result)
    end
    
  end
  
  # option (disabled)
  #
  def option(short, long='', msg='', default=nil, &b)
    @command_opts_parser ||= [OptionParser.new]
    @command_index ||= 0
    @command_options = OpenStruct.new
    
    current_opts_parser = @command_opts_parser[@command_index]
    
    on_args = []
    if short.is_a? Symbol
      short_str = "-#{short.to_s}"
      short_str += '=S' if (!default)
      on_args << short_str
    end
    
    if long.is_a? Symbol  
      long_str = "--#{long.to_s}"
      long_str += '=S' if (!default)
      on_args << long_str
    end
    
    on_args << msg if msg
#    pp on_args
    current_opts_parser.on(*on_args) do |v|
      block_args = [v, current_opts_parser]
      result = (b.nil?) ? v : b.call(block_args[0..(b.arity-1)])
      @command_options.send("#{long}=", result)
    end
  end
  
  def command(*cmds, &b)
    @command_index ||= -1
    puts "COPMMAND1: #{@command_index}"
    @command_index += 1
    puts "COPMMAND2: #{@command_index}"
    cmds.each do |cmd| 
      c = Command.new(cmd, @command_index, &b)
      (@commands ||= {})[cmd] = c
    end
  end
  
  def alias_command(aliaz, cmd)
    return unless @commands.has_key? cmd
    @commands[aliaz] = @commands[cmd]
  end
  
  def run!(argv, stdin=nil)
    raise NoCommandsDefined.new unless @commands
    global_argv, cmd, command_argv = process_arguments(argv)
    
    exit
    cmd ||= @default_command
    
    # This applies the configuration above to the arguments provided. It
    # removes the known named options from @global_argv leaving only the
    # unnamed arguments. It will raise InvalidOption for unknown options. 
    #@global_opts_parser.parse!(global_argv)
    
    raise UnknownCommand.new(cmd) unless command?(cmd)
    
    stdin = (defined? @stdin_block) ? @stdin_block.call(stdin, []) : stdin
    @before_block.call if defined? @before_block
    
    
    call_command(cmd, stdin, @global_options, command_argv)
    
    
  rescue OptionParser::InvalidOption => ex
    raise Frylock::InvalidArgument.new(ex)
  rescue OptionParser::MissingArgument => ex
    raise Frylock::MissingArgument.new(ex)
  end
  
  
  def call_command(cmd, stdin, options, command_argv)
    return unless command?(cmd)
    get_command(cmd).call(stdin, options, cmd, command_argv)
  end
  
  def get_command(cmd)
    return unless command?(cmd)
    @commands[canonize(cmd)]
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



  
