# frozen_string_literal: true

require 'sinatra/base'
require_relative '../clients/authentication_client'
require_relative '../clients/whois_client'

# Extend the Sinatra module to add a helper module
module Sinatra
  # Handles error that could arise
  module ValidationHelper
    APEX_DOMAIN_REGEX = /^(?!-)([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,63}$/i

    # Checks if API key is valid and not rate limited  as well as if domain is valid
    # @param api_key [String] the API key to validate
    # @param domain [String] the domain to validate
    # @param authentication_client [AuthenticationClient] the client to use for authentication
    # @raise [AuthenticationClient::NoApiKeyError] if no API key is provided
    # @raise [AuthenticationClient::RateLimitError] if too many requests have been made
    # @raise [WhoisClient::BadDomainError] if the domain is invalid
    def validate_authentication_and_domain!(api_key, domain, authentication_client)
      validate_authentication!(api_key, authentication_client)
      validate_domain!(domain, api_key)
    end

    private

    def validate_domain!(domain, api_key)
      raise WhoisClient::SubDomainError.new(domain, api_key) if domain&.count('.')&.> 1
      raise WhoisClient::BadDomainError if domain.nil? || domain.empty? || !domain.match?(APEX_DOMAIN_REGEX)
    end

    def validate_authentication!(api_key, authentication_client)
      raise AuthenticationClient::NoApiKeyError if api_key.nil? || api_key.empty?
      raise AuthenticationClient::RateLimitError unless authentication_client.authenticated_and_within_limit?(api_key)
    end
  end

  helpers ValidationHelper
end
