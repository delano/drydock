@spec = Gem::Specification.new do |s|
  s.name = %q{drydock}
  s.version = "0.4.0"
  s.specification_version = 1 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.authors = ["Delano Mandelbaum"]
  s.date = %q{2008-08-17}
  s.description = %q{A seaworthy DSL for writing command line apps inspired by Blake Mizerany's Frylock}
  s.email = %q{delano@solutious.com}
  s.files = %w(
    CHANGES.txt
    LICENSE.txt
    README.rdoc
    Rakefile
    bin/example
    drydock.gemspec
    lib/drydock.rb
    test/command_test.rb
    doc
    doc/classes
    doc/classes/Drydock
    doc/classes/Drydock/Command.html
    doc/classes/Drydock/InvalidArgument.html
    doc/classes/Drydock/MissingArgument.html
    doc/classes/Drydock/NoCommandsDefined.html
    doc/classes/Drydock/UnknownCommand.html
    doc/classes/Drydock.html
    doc/created.rid
    doc/files
    doc/files/bin
    doc/files/bin/example.html
    doc/files/CHANGES_txt.html
    doc/files/lib
    doc/files/lib/drydock_rb.html
    doc/files/LICENSE_txt.html
    doc/files/README_rdoc.html
    doc/fr_class_index.html
    doc/fr_file_index.html
    doc/fr_method_index.html
    doc/index.html
    doc/rdoc-style.css
  )
  s.has_rdoc = true
  s.homepage = %q{http://github.com/delano/drydock}
  s.extra_rdoc_files = %w[README.rdoc LICENSE.txt CHANGES.txt]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Drydock: a seaworthy DSL for command-line apps", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{A seaworthy DSL for writing command line apps}
  
  s.rubyforge_project = "drydock"
end
