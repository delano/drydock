# frozen_string_literal: true

require_relative 'lib/drydock'

Gem::Specification.new do |spec|
  spec.name          = 'drydock'
  spec.version       = Drydock::VERSION
  spec.authors       = ['Delano Mandelbaum']
  spec.email         = ['delano@solutious.com']

  spec.summary       = 'Build seaworthy command-line apps like a Captain with a powerful Ruby DSL.'
  spec.description   = 'Drydock provides a powerful DSL for building command-line applications with ease. ' \
                      'Create complex CLIs with nested commands, argument parsing, and validation using ' \
                      'an intuitive Ruby DSL that makes your code both readable and maintainable.'
  spec.homepage      = 'https://github.com/delano/drydock'
  spec.license       = 'MIT'

  spec.metadata = {
    'bug_tracker_uri'   => 'https://github.com/delano/drydock/issues',
    'changelog_uri'     => 'https://github.com/delano/drydock/blob/main/CHANGES.txt',
    'documentation_uri' => 'https://rubydoc.info/gems/drydock',
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => 'https://github.com/delano/drydock',
    'rubygems_mfa_required' => 'true'
  }

  spec.required_ruby_version = '>= 3.0.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  # (none currently - keeping it lightweight)

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
  spec.add_development_dependency 'rdoc', '~> 6.0'

  # Documentation
  spec.extra_rdoc_files = %w[README.md LICENSE.txt CHANGES.txt]
  spec.rdoc_options = [
    '--line-numbers',
    '--title', "Drydock: #{spec.description}",
    '--main', 'README.md',
    '--charset=UTF-8'
  ]
end