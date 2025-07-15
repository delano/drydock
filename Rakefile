require 'bundler/gem_tasks'
require 'rake/clean'
require 'rdoc/task'

task default: :test

# SPECS ===============================================================

desc 'Run tests'
task :test do
  if File.exist?('spec') && system('which rspec > /dev/null 2>&1')
    sh 'bundle exec rspec'
  else
    sh 'ruby test/*_test.rb'
  end
end

desc 'Run bin/example and tryouts'
task :tryouts do
  sh 'ruby bin/example'
end

# DOCUMENTATION =======================================================

RDoc::Task.new(:rdoc) do |t|
  t.rdoc_dir = 'doc'
  t.title = 'Drydock - Build seaworthy command-line apps'
  t.options << '--line-numbers' << '--charset=utf-8'
  t.rdoc_files.include('LICENSE.txt')
  t.rdoc_files.include('README.md')
  t.rdoc_files.include('CHANGES.txt')
  t.rdoc_files.include('bin/*')
  t.rdoc_files.include('lib/**/*.rb')
end

# DEVELOPMENT =========================================================

desc 'Run RuboCop'
task :rubocop do
  sh 'bundle exec rubocop'
end

desc 'Run RuboCop with auto-correct'
task 'rubocop:auto_correct' do
  sh 'bundle exec rubocop -a'
end

desc 'Install development dependencies'
task :setup do
  sh 'bundle install'
end

# ALIASES =============================================================

task lint: :rubocop
task doc: :rdoc

# CLEAN ===============================================================

CLEAN.include ['pkg', '*.gem', '.config', 'doc', 'coverage']
