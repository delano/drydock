require 'rubygems'
require 'rake/clean'
require 'rake/gempackagetask'
require 'hanna/rdoctask'
require 'fileutils'
include FileUtils
 
task :default => :test
 
# SPECS ===============================================================
 
desc 'Run specs with unit test style output'
task :test do |t|
  sh "ruby tests/*_test.rb"
end

# PACKAGE =============================================================


require File.dirname(__FILE__) + "/lib/drydock"
load "drydock.gemspec"

version = Drydock::VERSION.to_s

Drydock.run = false


Rake::GemPackageTask.new(@spec) do |p|
	p.need_tar = true if RUBY_PLATFORM !~ /mswin/
end

task :release => [ :rdoc, :package ]

task :install => [ :rdoc, :package ] do
	sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [ :clean ] do
	sh %{sudo gem uninstall #{name}}
end


# Rubyforge Release / Publish Tasks ==================================

desc 'Publish website to rubyforge'
task 'publish:doc' => 'doc/index.html' do
  sh 'scp -rp doc/* rubyforge.org:/var/www/gforge-projects/drydock/'
end

task 'publish:gem' => [:package] do |t|
  sh <<-end
    rubyforge add_release drydock drydock #{@spec.version} pkg/drydock-#{@spec.version}.gem &&
    rubyforge add_file    drydock drydock #{@spec.version} pkg/drydock-#{@spec.version}.tar.gz
  end
end


Rake::RDocTask.new do |t|
	t.rdoc_dir = 'doc'
	t.title    = "Drydock, A seaworthy DSL for command-line apps."
	t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
	t.options << '--charset' << 'utf-8'
	t.rdoc_files.include('LICENSE.txt')
	t.rdoc_files.include('README.rdoc')
	t.rdoc_files.include('CHANGES.txt')
	t.rdoc_files.include('bin/*')
	t.rdoc_files.include('lib/*.rb')
end

CLEAN.include [ 'pkg', '*.gem', '.config', 'doc' ]



