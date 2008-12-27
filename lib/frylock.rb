require 'optparse'
require 'ostruct'
require 'pp'

module Frylock
  class UnknownCommand < RuntimeError
    attr_reader :name
    def initialize(name)
      @name = name
    end
    def message
      msg = "Frylock: I don't know what that command is. #{$/}"
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
    attr_accessor :name
    def initialize(ex)
      # We grab just the name of the argument
      @name = ex.message.gsub('invalid option: ', '')
    end
  end
  class MissingArgument < RuntimeError
    attr_accessor :name
    def initialize(ex)
      # We grab just the name of the argument
      @name = ex.message.gsub('missing argument: ', '')
    end
    def message
      msg = "Frylock: Shake, how many arguments have you broken this year? #{$/}"
      msg << "Master Shake: A *lot* more than *you* have! (#{@name})"
    end
  end
  
end

module Frylock
  class Command
    def initialize(cmd, &b)
      @cmd = (cmd.kind_of?(Symbol)) ? cmd.to_s : cmd
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
  end
end

module Frylock
  extend self
  
  FORWARDED_METHODS = %w(command before alias_command options stdin default)

  def default(cmd)
    @default_command = canonize(cmd)
  end
  
  def stdin(&b)
    @stdin_block = b
  end
  def before(&b)
    @before_block = b
  end
  def options(cmd=false, &b)
    
    @opts ||= OptionParser.new 
    @options ||= OpenStruct.new
    
    b.call(@opts, @options)
          
  end
  
  # option_banner (disabled)
  # ex: option_banner "Usage: frylla [global options] command [command options]"
  def option_banner(msg)
    @opts ||= OptionParser.new 
    @options ||= OpenStruct.new
  
    @opts.banner = msg
  end
  
  # option (disabled)
  #
  # Examples:
  # option :p, "Make poop" do |v|
  #   v
  # end
  # 
  # option :h, :help, "Display this message", true do |v, parser|
  #   puts parser
  #   exit 0
  # end
  def option(short, long='', msg='', value=nil, &b)
    @opts ||= OptionParser.new 
    @options ||= OpenStruct.new
    
    on_args = []
    
    if short.is_a? Symbol
      short_str = "-#{short.to_s}"
      short_str += '=S' if (!value)
      on_args << short_str
    end
    
    if long.is_a? Symbol  
      long_str = "--#{long.to_s}"
      long_str += '=S' if (!value)
      on_args << long_str
    end
    
    on_args << msg if msg
    pp on_args
    @opts.on(*on_args) do |v|
      block_args = [v, @opts]
      result = (b.nil?) ? v : b.call(block_args[0..(b.arity-1)])
      @options.send("#{long}=", result)
    end
  end
  
  def command(*cmds, &b)
    cmds.each do |cmd| 
      c = Command.new(cmd, &b)
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
    
    cmd ||= @default_command
    
    # This applies the configuration above to the arguments provided. It
    # removes the known named options from @global_argv leaving only the
    # unnamed arguments. It will raise InvalidOption for unknown options. 
    @opts.parse!(global_argv)
    
    raise UnknownCommand.new(cmd) unless command?(cmd)
    
    stdin = (defined? @stdin_block) ? @stdin_block.call(stdin, []) : stdin
    @before_block.call if defined? @before_block
    
    
    call_command(cmd, stdin, @options, command_argv)
    
    
  rescue OptionParser::InvalidOption => ex
    raise Frylock::InvalidArgument.new(ex)
  rescue OptionParser::MissingArgument => ex
    raise Frylock::MissingArgument.new(ex)
  end

  def call_command(cmd, stdin, options, command_argv)
    return unless command?(cmd)
    @commands[canonize(cmd)].call(stdin, options, cmd, command_argv)
  end
  
  
  # process_arguments
  #
  # Split the +argv+ array into global args and command args and 
  # find the command name. 
  # i.e. ./script -H push -f (-H is a global arg, push is the command, -f is a command arg)
  # returns [global_argv, cmd, command_argv]
  def process_arguments(argv)
    global_argv = command_argv = []
    cmd = nil     
    argv.each do |arg|
      if (command? arg)
        cmd = arg 
        index = argv.index(cmd)
        command_argv = argv[index + 1..argv.size] 
        global_argv = argv[0..index - 1] if index > 0
        break
      end
    end

    # If there's no command we'll assume all global arguments 
    global_argv = argv unless cmd
    
    [global_argv, cmd, command_argv]
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



  
