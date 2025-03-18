# frozen_string_literal: true

require 'securerandom'

# A client for validating API Keys and rate limits
class AuthenticationClient
  API_KEY_INSERT_STATEMENT = <<~SQL
    INSERT INTO api_keys (api_key, email, validation_code)
    VALUES ($1, $2, $3)
  SQL

  REQUESTS_INSERT_STATEMENT = <<~SQL
    INSERT INTO requests (api_key_id, time)
    VALUES ($1, now())
    ON CONFLICT DO NOTHING
  SQL

  SELECT_QUERY = <<~SQL
    SELECT COUNT(*) FROM requests
    WHERE requests.api_key_id = $1 AND requests.time >= NOW() - INTERVAL '5 minutes'
  SQL

  def initialize(db_client)
    @db_client = db_client
  end

  def authenticated_and_within_limit?(api_key)
    api_key_result = @db_client.exec_params 'SELECT id FROM api_keys WHERE api_key = $1 AND email_verified = TRUE',
                                            [api_key]
    raise InvalidApiKeyError if api_key_result.ntuples.zero?

    api_key_id = api_key_result.first['id']
    count = @db_client.exec_params SELECT_QUERY, [api_key_id]
    count.first['count'].to_i <= 15
  end

  def issue_api_key!(email_address)
    api_key = SecureRandom.uuid
    validation_code = SecureRandom.hex 3 # 6 characters
    @db_client.exec_params API_KEY_INSERT_STATEMENT, [api_key, email_address, validation_code]
  rescue PG::UniqueViolation => e
    e.full_message.match(/Key\s*\((?<key>[^)]+)\)=\((?<value>[^)]+)\)/) => { key:, value: }
    raise DbClient::NonUniqueKVError.new(key, value)
  end

  private

  def record_request!(api_key_id)
    @db_client.exec_params REQUESTS_INSERT_STATEMENT, [api_key_id]
  end

  class InvalidApiKeyError < StandardError; end
  class NoApiKeyError < StandardError; end
  class RateLimitError < StandardError; end
end
