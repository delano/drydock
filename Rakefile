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



task :install => [ :rdoc, :package ] do
	sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [ :clean ] do
	sh %{sudo gem uninstall #{name}}
end


# Rubyforge Release / Publish Tasks ==================================

desc 'Publish website to rubyforge'
task 'publish:doc' => 'doc/index.html' do
  sh 'scp -rp doc/* rubyforge.org:/var/www/gforge-projects/stella/'
end

#task 'publish:gem' => [package('.gem'), package('.tar.gz')] do |t|
#  sh <<-end
#    rubyforge add_release stella stella #{spec.version} #{package('.gem')} &&
#    rubyforge add_file    stella stella #{spec.version} #{package('.tar.gz')}
#  end
#end


Rake::RDocTask.new do |t|
	t.rdoc_dir = 'doc'
	t.title    = "stella, a friend in performance testing"
	t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
	t.options << '--charset' << 'utf-8'
	t.rdoc_files.include('LICENSE.txt')
	t.rdoc_files.include('README.rdoc')
	t.rdoc_files.include('CHANGES.txt')
	t.rdoc_files.include('bin/*')
	t.rdoc_files.include('lib/*.rb')
end

CLEAN.include [ 'pkg', '*.gem', '.config', 'doc' ]



