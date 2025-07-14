# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.2.0'

gemspec

group :development, :test do
  gem 'rspec', '~> 3.12'
  gem 'rubocop', '~> 1.57'
  gem 'rubocop-rake', '~> 0.6'
  gem 'rubocop-rspec', '~> 2.25'
  gem 'simplecov', '~> 0.22', require: false
  gem 'yard', '~> 0.9'
end

group :development do
  gem 'bundler-audit', '~> 0.9'
  gem 'pry', '~> 0.14'
  gem 'rake', '~> 13.0'
  gem 'rdoc', '~> 6.5'
end

group :test do
  gem 'rspec-collection_matchers', '~> 1.2'
end
