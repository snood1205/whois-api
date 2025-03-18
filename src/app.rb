# frozen_string_literal: true

require 'sinatra/base'
require 'pg'
require 'dotenv/load'
require_relative 'clients/authentication_client'
require_relative 'clients/db_client'
require_relative 'clients/whois_client'
require_relative 'sinatra/error_handling'
require_relative 'sinatra/validation'

# The base class for the application
class App < Sinatra::Base
  helpers Sinatra::ErrorHandlingHelper
  helpers Sinatra::ValidationHelper

  LOGGER = Logger.new 'debug.log'

  pg_client = DbClient.open(
    dbname:   ENV.fetch('DB_NAME'),
    user:     ENV.fetch('DB_USER'),
    password: ENV.fetch('DB_PASSWORD')
  )
  authentication_client = AuthenticationClient.new(pg_client)
  whois_client = WhoisClient.new(pg_client)

  configure do
    set :host_authorization, { permitted_hosts: %w[whois.gitgetgot.dev localhost 127.0.0.1] }
  end

  get '/get-info' do
    handle_errors do
      api_key = params[:api_key]
      domain = params[:domain]
      validate_authentication_and_domain!(api_key, domain, authentication_client)

      info = whois_client.whois_info(domain)
      body info.to_json
    end
  end
end
