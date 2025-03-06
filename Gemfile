# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gem 'dotenv'
gem 'logger', '~> 1.6'
gem 'pg'
gem 'puma', '~> 6.6'
gem 'rackup', '~> 2.2'
gem 'sinatra'

group :development do
  gem 'rubocop', '~> 1.72', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rspec', require: false
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'activerecord'
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'rack-test'
  gem 'rspec'
end
