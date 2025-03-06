# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../src/app'

require 'active_record'
require 'database_cleaner/active_record'
require 'dotenv'
require 'factory_bot'
require 'json'
require 'pry'
require 'rack/test'
require 'rspec'

Dotenv.load '.env.test'

ActiveRecord::Base.establish_connection \
  adapter:  'postgresql',
  database: ENV.fetch('DB_NAME'),
  username: ENV.fetch('DB_USER'),
  password: ENV.fetch('DB_PASSWORD', ''),
  host:     ENV.fetch('DB_HOST', 'localhost')

class ApiKey < ActiveRecord::Base; end
class Domain < ActiveRecord::Base; end
class Request < ActiveRecord::Base; end

module Rack::Test::Methods
  def build_rack_mock_session
    Rack::MockSession.new app, 'whois.gitgetgot.dev'
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  def app
    App
  end

  config.before :suite do
    FactoryBot.find_definitions
    DatabaseCleaner[:active_record].strategy = :truncation
    DatabaseCleaner[:active_record].clean_with(:truncation)
  end

  config.around do |ex|
    DatabaseCleaner[:active_record].cleaning { ex.run }
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
