# Drydock - v1.0

**Build seaworthy command-line apps like a Captain with a powerful Ruby DSL.**

## Overview

Drydock is a seaworthy DSL for building really powerful command line applications. The core class is contained in a single .rb file so it's easy to copy directly into your project. See below for examples.

## Install

One of:

* `gem install drydock`
* copy `lib/drydock.rb` into your `lib` directory.

Or for GitHub fans:

* `git clone git://github.com/delano/drydock.git`
* `gem install delano-drydock`

## Examples

See `bin/example` for more.

```ruby
require 'drydock'
extend Drydock

default :welcome

before do
  # You can execute a block before the requests command is executed. Instance
  # variables defined here will be available to all commands.
end

about "A friendly welcome to the Drydock"
command :welcome do
  puts "Welcome to Drydock."
  puts "For available commands:"
  puts "#{$0} show-commands"
end

usage "USAGE: #{$0} laugh [-f]"
about "The captain commands his crew to laugh"
option :f, :faster, "A boolean value. Go even faster!"
command :laugh do |obj|
  # +obj+ is an instance of Drydock::Command. The options you define are available
  # via obj.option.name

  answer = !obj.option.faster ? "Sort of" : "Yes! I'm literally laughing as fast as possible."

  puts "Captain Stubing: Are you laughing?"
  puts "Dr. Bricker: " << answer
end

class JohnWestSmokedOysters < Drydock::Command
  # You can write your own command classes by inheriting from Drydock::Command
  # and referencing it in the command definition.
  def ahoy!; p "matey"; end
end

about "Do something with John West's Smoked Oysters"
command :oysters => JohnWestSmokedOysters do |obj|
  p obj  # => #<JohnWestSmokedOysters:0x42179c ... >
end

about "My way of saying hello!"
command :ahoy! => JohnWestSmokedOysters
# If you don't provide a block, Drydock will call JohnWestSmokedOysters#ahoy!

Drydock.run!
```

## More Information

* [GitHub](http://github.com/delano/drydock)
* [RDocs](http://drydock.rubyforge.org/)
* [Inspiration](http://www.youtube.com/watch?v=m_wFEB4Oxlo)

## Thanks

* Solutious Inc for putting up with my endless references to the sea! ([http://solutious.com](http://solutious.com))
* Blake Mizerany for the inspiration via [bmizerany-frylock](http://github.com/bmizerany/frylock)

## Credits

* Delano Mandelbaum (delano@solutious.com)
* Bernie Kopell (bernie@solutious.com)

## License

See LICENSE.txt
