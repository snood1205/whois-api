# frozen_string_literal: true

require 'sinatra/base'

# Extend the Sinatra module to add a helper module
module Sinatra
  # Handles error that could arise
  module ErrorHandlingHelper
    def handle_errors(&)
      handle_authentication_errors { handle_whois_errors { handle_standard_error(&) } }
    end

    def handle_authentication_errors
      yield
    rescue AuthenticationClient::InvalidApiKeyError
      status 401
      body({ error: 'Invalid API key provided' }.to_json)
    rescue AuthenticationClient::NoApiKeyError
      status 401
      body({ error: 'No API key provided' }.to_json)
    rescue AuthenticationClient::RateLimitError
      status 429
      body({ error: 'Too many requests' }.to_json)
    end

    def handle_standard_error
      yield
    rescue StandardError => e
      raise e if ENV['RACK_ENV'] == 'development'

      status 500
      body({ error: 'Internal server error' }.to_json)
    end

    def handle_subdomain_error(error)
      status 302
      headers 'Location' => "/get-info?api_key=#{error.api_key}&domain=#{error.apex_domain}"
      body({ error: error.message }.to_json)
    end

    def handle_whois_errors
      yield
    rescue WhoisClient::SubDomainError => e
      handle_subdomain_error(e)
    rescue WhoisClient::BadDomainError
      status 400
      body({ error: 'Bad domain' }.to_json)
    rescue WhoisClient::ExpiredDomainError => e
      status 410
      body({ error: "Domain #{e.domain} expired on #{e.expiration_date}" }.to_json)
    end
  end

  helpers ErrorHandlingHelper
end
