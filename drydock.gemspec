# frozen_string_literal: true

require_relative 'lib/drydock'

Gem::Specification.new do |spec|
  spec.name          = 'drydock'
  spec.version       = Drydock::VERSION
  spec.authors       = ['Delano Mandelbaum']
  spec.email         = ['delano@solutious.com']

  spec.summary       = 'Build seaworthy command-line apps like a Captain with a powerful Ruby DSL.'
  spec.description   = 'Drydock provides a powerful DSL for building command-line applications with ease.'
  spec.homepage      = 'https://github.com/delano/drydock'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.2.0'

  spec.files = %w[
    CHANGES.txt
    LICENSE.txt
    README.md
    Rakefile
    bin/example
    drydock.gemspec
    lib/drydock.rb
    lib/drydock/console.rb
    lib/drydock/mixins.rb
    lib/drydock/mixins/object.rb
    lib/drydock/mixins/string.rb
    lib/drydock/screen.rb
  ]

  spec.bindir        = 'bin'
  spec.executables   = ['example']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_runtime_dependency 'ostruct', '~> 0.6'

  spec.extra_rdoc_files = %w[README.md LICENSE.txt CHANGES.txt]
  spec.rdoc_options = ['--line-numbers', '--title', 'Drydock', '--main', 'README.md']
end
