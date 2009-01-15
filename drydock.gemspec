Gem::Specification.new do |s|
  s.name = %q{drydock}
  s.version = "0.3.0"
  s.specification_version = 1 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.authors = ["Delano Mandelbaum", "Blake Mizerany"]
  s.date = %q{2008-08-17}
  s.description = %q{Command line apps made easy}
  s.email = %q{delano@solutious.com}
  s.files = %w(
    LICENSE.txt
    README.rdoc
    bin/example
    lib/drydock/exceptions.rb
    lib/drydock.rb
  )
  s.has_rdoc = true
  s.homepage = %q{http://github.com/delano/drydock}
  s.extra_rdoc_files = %w[README.rdoc LICENSE.txt]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Drydock: Easy command-line apps", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Command line apps made easy}
end
